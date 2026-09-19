#!/bin/bash
# rotate-workspaces.sh - send every monitor's visible workspace to the next monitor.
# Pressed with two monitors this is exactly a swap of the two visible workspaces.
#
# WHY NOT move-workspace-to-monitor
# ---------------------------------
# It always replaces the workspace left behind on the origin monitor with a stub, and
# AeroSpace picks that stub with Workspace.getStubWorkspace, which tries, in order:
#   1. the workspace that monitor showed before the current one
#   2. any invisible workspace still owned by that monitor
#   3. a fresh empty numeric workspace
# Branches 1 and 2 hand out a workspace that still holds windows, and that is the
# workspace with real content that flashes mid-swap.
#
# HOW THIS SCRIPT MOVES A WORKSPACE
# ---------------------------------
# It never leaves a workspace behind for AeroSpace to stub: every workspace it moves
# is already hidden, and `summon-workspace` only creates a stub when the summoned
# workspace was visible on another monitor (prevMonitor != nil in the command). So a
# pair of monitors is rotated as:
#
#   1. blank the origin monitor with an empty scratch workspace: the workspace the
#      origin showed becomes hidden but stays assigned to that monitor
#   2. summon that hidden workspace onto the next monitor (hidden => no stub)
#   3. summon the next monitor's workspace, hidden since step 2, back onto the origin
#
# The only thing ever shown in between is an empty scratch workspace, so the flash
# shows the wallpaper, never someone else's workspace. After the rotation the scratch
# is empty, invisible and not in `persistent-workspaces`, so AeroSpace garbage
# collects it (Workspace.garbageCollectUnusedWorkspaces) and nothing is left behind.
#
# EVERY STEP IS VERIFIED
# ----------------------
# After every step the script re-reads what the monitors show. If that is not what it
# just asked for, something else changed the workspaces mid-rotation (a workspace
# binding, a click on a sketchybar space item, a window rule). The script then stops,
# puts back only what is demonstrably still its own scratch workspace, and says so
# instead of fighting whatever else is going on.
#
# SCRATCH WORKSPACES
# ------------------
# A scratch workspace is used only while it is invisible AND empty. If a window lands
# on it (AeroSpace puts new windows on the active workspace of their monitor) the
# scratch keeps that window, stops being empty and is skipped from then on. To rescue
# such a window and let AeroSpace garbage collect the scratch again:
#   aerospace list-windows --workspace blank-a
#   aerospace move-node-to-workspace --window-id <window-id> <workspace>
#
# FORCE-ASSIGNED WORKSPACES
# -------------------------
# A workspace pinned by `workspace-to-monitor-force-assignment` cannot leave its
# monitor. AeroSpace refuses the move before changing anything, the script then puts
# back the workspace it had blanked and reports which workspace could not move.
set -u

# exec-and-forget runs with the app environment, not with the login shell one.
AEROSPACE="${AEROSPACE:-/opt/homebrew/bin/aerospace}"
PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

# Empty throwaway workspaces, used only as the blank in-between state. Workspace names
# may not start with "_" or "-", may not contain commas or whitespace, and may not be
# one of AeroSpace's reserved words (focused, visible, next, ...).
BLANKS="blank-a blank-b blank-c"

notify() {
  local message
  message=$(printf '%s' "$1" | tr -d '"')
  /usr/bin/osascript -e "display notification \"$message\" with title \"AeroSpace\"" >/dev/null 2>&1 || true
}

fail() {
  notify "$1"
  echo "rotate-workspaces: $1" >&2
  exit 1
}

warn() {
  notify "$1"
  echo "rotate-workspaces: $1" >&2
}

[ -x "$AEROSPACE" ] || fail "aerospace CLI not found at $AEROSPACE"

# Ignore a second key press while this one is still running. A run killed midway can
# leave a blank workspace visible: pressing any workspace binding fixes it.
lock="/tmp/aerospace-rotate-workspaces.$UID.lock"
if [ -d "$lock" ]; then
  holder=$(cat "$lock/pid" 2>/dev/null)
  if [ -n "$holder" ] && kill -0 "$holder" 2>/dev/null; then
    exit 0
  fi
  rm -rf "$lock"
fi
mkdir "$lock" || exit 0
echo $$ >"$lock/pid"
trap 'rm -rf "$lock"' EXIT

# Monitors in AeroSpace's own next/prev order: left to right, top to bottom.
monitors=()
while IFS= read -r id || [ -n "$id" ]; do
  [ -n "$id" ] && monitors+=("$id")
done < <("$AEROSPACE" list-monitors --format '%{monitor-id}')
count=${#monitors[@]}
[ "$count" -ge 2 ] || exit 0

visible_workspace() { # $1 = monitor-id
  "$AEROSPACE" list-workspaces --monitor "$1" --visible --format '%{workspace}' | head -n 1
}

focused_index() { # index of the monitor holding the keyboard focus
  local focused i
  focused=$("$AEROSPACE" list-monitors --focused --format '%{monitor-id}')
  i=0
  while [ "$i" -lt "$count" ]; do
    if [ "${monitors[$i]}" = "$focused" ]; then
      echo "$i"
      return 0
    fi
    i=$((i + 1))
  done
  echo 0
}

focus_monitor_at() { # $1 = target index, always adjacent to the current focus
  local target current next prev
  target=$1
  current=$(focused_index)
  [ "$current" = "$target" ] && return 0
  next=$(((current + 1) % count))
  prev=$(((current + count - 1) % count))
  if [ "$next" = "$target" ]; then
    "$AEROSPACE" focus-monitor --wrap-around next >/dev/null || return 1
  elif [ "$prev" = "$target" ]; then
    "$AEROSPACE" focus-monitor --wrap-around prev >/dev/null || return 1
  else
    die_internal "monitor $current -> $target is not an adjacent step"
  fi
}

die_internal() {
  warn "internal error: $1"
  exit 1
}

# 0 = moved, 1 = AeroSpace refused the move (its message goes to stderr),
# 2 = that workspace was already visible on the focused monitor
summon_workspace() { # $1 = workspace
  local output rc
  output=$("$AEROSPACE" summon-workspace "$1" 2>&1)
  rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '%s\n' "$output" >&2
    return 1
  fi
  case "$output" in
  *"already visible on the focused monitor"*) return 2 ;;
  esac
  return 0
}

# The first scratch workspace that is currently invisible and empty.
pick_blank() {
  local name visible_list occupied_list
  visible_list=$("$AEROSPACE" list-workspaces --monitor all --visible --format '%{workspace}')
  occupied_list=$("$AEROSPACE" list-workspaces --monitor all --empty no --format '%{workspace}')
  for name in $BLANKS; do
    printf '%s\n' "$visible_list" | grep -Fxq "$name" && continue
    printf '%s\n' "$occupied_list" | grep -Fxq "$name" && continue
    printf '%s\n' "$name"
    return 0
  done
  return 1
}

# The scratch workspace this run created, "" when it is not showing anywhere.
scratch=""
# Set when the workspaces moved under us: stop changing them.
stale=0
# The workspace and monitor index AeroSpace refused to move, for the report.
blocked_ws=""
blocked_monitor=""

# Does the monitor show what we just asked for?
expect() { # $1 = monitor-id, $2 = expected workspace, $3 = what was being done
  local got
  got=$(visible_workspace "$1")
  if [ "$got" != "$2" ]; then
    warn "$3: monitor $1 shows '$got', expected '$2'. Another key press or click changed the workspaces mid-rotation; stopping instead of fighting it"
    stale=1
    return 1
  fi
  return 0
}

blank_monitor() { # $1 = monitor index; its workspace becomes hidden behind $scratch
  local index=$1 name rc
  name=$(pick_blank) || {
    warn "no empty scratch workspace left (${BLANKS}); see the notes at the top of this script"
    return 1
  }
  focus_monitor_at "$index" || return 1
  summon_workspace "$name"
  rc=$?
  [ "$rc" -eq 0 ] || return 1
  scratch=$name
  expect "${monitors[$index]}" "$name" "could not blank monitor ${monitors[$index]}" || return 1
  return 0
}

is_visible_anywhere() { # $1 = workspace
  "$AEROSPACE" list-workspaces --monitor all --visible --format '%{workspace}' | grep -Fxq "$1"
}

# Put back what the two monitors showed. The blank workspace this run created is always
# moved out of the way; a workspace somebody else made visible is left alone. With
# mode "exact" it also puts back AeroSpace's own stub on the other monitor, which is
# what a refused move needs; with mode "scratch" it does not, so a workspace that
# somebody else switched to mid-rotation is not fought over.
unwind_pair() { # $1/$2 = origin/target index, $3/$4 = the workspaces that belong there, $5 = exact|scratch
  local o=$1 t=$2 wo=$3 wt=$4 mode=${5-exact} origin_id target_id got
  origin_id=${monitors[$o]}
  target_id=${monitors[$t]}
  if [ -n "$scratch" ]; then
    if [ "$(visible_workspace "$origin_id")" = "$scratch" ]; then
      if focus_monitor_at "$o" && summon_workspace "$wo" >/dev/null 2>&1 &&
        [ "$(visible_workspace "$origin_id")" = "$wo" ]; then
        :
      else
        warn "could not put workspace '$wo' back on monitor $origin_id"
      fi
    elif [ "$(visible_workspace "$target_id")" = "$scratch" ]; then
      if focus_monitor_at "$t" && summon_workspace "$wt" >/dev/null 2>&1 &&
        [ "$(visible_workspace "$target_id")" = "$wt" ]; then
        :
      else
        warn "could not put workspace '$wt' back on monitor $target_id"
      fi
    else
      warn "blank workspace '$scratch' is not showing anywhere any more; leaving the workspaces alone"
    fi
    scratch=""
  fi
  # Putting a workspace back can leave AeroSpace's own stub behind on the other monitor.
  [ "$mode" = "exact" ] || return 0
  got=$(visible_workspace "$target_id")
  if [ "$got" != "$wt" ]; then
    if is_visible_anywhere "$wt"; then
      warn "monitor $target_id shows '$got' instead of '$wt', and '$wt' is visible on another monitor; leaving it alone"
    elif focus_monitor_at "$t" && summon_workspace "$wt" >/dev/null 2>&1; then
      [ "$(visible_workspace "$target_id")" = "$wt" ] || warn "could not put workspace '$wt' back on monitor $target_id"
    else
      warn "could not put workspace '$wt' back on monitor $target_id"
    fi
  fi
}

swap_pair() { # $1/$2 = origin/target index, $3/$4 = origin/target visible workspace
  local o=$1 t=$2 wo=$3 wt=$4 rc
  scratch=""
  blank_monitor "$o" || return 1 # wo becomes hidden, still assigned to o
  if ! focus_monitor_at "$t"; then
    unwind_pair "$o" "$t" "$wo" "$wt"
    return 1
  fi
  summon_workspace "$wo" # hidden => no stub on the target
  rc=$?
  if [ "$rc" -eq 2 ]; then
    # 'already visible on the focused monitor': the world is not what we just read
    warn "monitor ${monitors[$t]} already showed workspace '$wo'; something else changed the workspaces mid-rotation"
    stale=1
    unwind_pair "$o" "$t" "$wo" "$wt" scratch
    return 1
  fi
  if [ "$rc" -ne 0 ]; then
    blocked_ws=$wo
    blocked_monitor=$t
    unwind_pair "$o" "$t" "$wo" "$wt"
    return 1
  fi
  expect "${monitors[$t]}" "$wo" "workspace '$wo' did not land on monitor ${monitors[$t]}" || {
    unwind_pair "$o" "$t" "$wo" "$wt" scratch
    return 1
  }
  if ! focus_monitor_at "$o"; then
    unwind_pair "$o" "$t" "$wo" "$wt"
    return 1
  fi
  summon_workspace "$wt" # hidden since the step above => no stub
  rc=$?
  if [ "$rc" -ne 0 ]; then
    blocked_ws=$wt
    blocked_monitor=$o
    unwind_pair "$o" "$t" "$wo" "$wt"
    return 1
  fi
  expect "${monitors[$o]}" "$wt" "workspace '$wt' did not land on monitor ${monitors[$o]}" || {
    unwind_pair "$o" "$t" "$wo" "$wt" scratch
    return 1
  }
  scratch=""
  return 0
}

origin_focus=$(focused_index)

pair_o=()
pair_t=()
if [ "$count" -eq 2 ]; then
  # Either order is the same swap, so start from the focused monitor: then neither the
  # first nor the last step has to move the keyboard focus around.
  pair_o+=("$origin_focus")
  pair_t+=("$(((origin_focus + 1) % count))")
else
  # More than two monitors: rotate the visible workspaces one monitor over, as N-1
  # adjacent swaps. Only the two monitor case has been exercised on a real setup.
  i=0
  while [ "$i" -lt "$((count - 1))" ]; do
    pair_o+=("$i")
    pair_t+=("$((i + 1))")
    i=$((i + 1))
  done
fi

completed_o=()
completed_t=()
completed_wo=()
completed_wt=()

rollback_completed() { # best effort: undo finished pairs, newest first
  local i
  i=$((${#completed_o[@]} - 1))
  while [ "$i" -ge 0 ]; do
    if ! swap_pair "${completed_o[$i]}" "${completed_t[$i]}" "${completed_wt[$i]}" "${completed_wo[$i]}"; then
      warn "could not undo the swap on monitor ${monitors[${completed_o[$i]}]}"
      return 1
    fi
    i=$((i - 1))
  done
}

i=0
while [ "$i" -lt "${#pair_o[@]}" ]; do
  origin=${pair_o[$i]}
  target=${pair_t[$i]}
  wo=$(visible_workspace "${monitors[$origin]}")
  wt=$(visible_workspace "${monitors[$target]}")
  if [ -n "$wo" ] && [ -n "$wt" ] && [ "$wo" != "$wt" ]; then
    if ! swap_pair "$origin" "$target" "$wo" "$wt"; then
      focus_monitor_at "$origin_focus" || true
      if [ "$stale" -eq 1 ]; then
        # Something else owns the workspaces right now: stop here and leave them alone.
        [ "${#completed_o[@]}" -gt 0 ] && warn "rotation incomplete: ${#completed_o[@]} monitor(s) already rotated"
        exit 1
      fi
      rollback_completed
      if [ -n "$blocked_ws" ]; then
        fail "workspace '$blocked_ws' could not move to monitor ${monitors[$blocked_monitor]} (workspace-to-monitor-force-assignment?); rotation undone"
      fi
      fail "could not rotate workspace '$wo' from monitor ${monitors[$origin]} to ${monitors[$target]}; rotation undone"
    fi
    completed_o+=("$origin")
    completed_t+=("$target")
    completed_wo+=("$wo")
    completed_wt+=("$wt")
  fi
  i=$((i + 1))
done

focus_monitor_at "$origin_focus" || true
