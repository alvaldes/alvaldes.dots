#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║          AEROSPACE ↔ SKETCHYBAR WORKSPACE CONTROLLER                         ║
# ║  Subscribes to AeroSpace events and directly updates SketchyBar items         ║
# ║  Handles: visibility (only visible workspaces shown), focus (accent),         ║
# ║           ordering (by monitor position, left → right)                       ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ── Colors (must match sketchybarrc) ──────────────────────────────────────────
ACCENT=0xffe0c15a
DIM=0xff565f89
ISLAND_BG=0xff121620
ISLAND_BORDER=0xff263356
BG_ON="on"
BG_OFF="off"

# ── Single-instance guard ──────────────────────────────────────────────────────
PID_FILE="/tmp/sketchybar_aerospace.pid"
if [ -f "$PID_FILE" ]; then
  OLD_PID=$(cat "$PID_FILE" 2>/dev/null)
  [ -n "$OLD_PID" ] && kill "$OLD_PID" 2>/dev/null
  sleep 0.2
fi
echo $$ >"$PID_FILE"

# ── Helper: update all workspace items based on current AeroSpace state ─────────
update_workspaces() {
  # Get ALL workspaces (to hide non-visible ones)
  ALL_WS=$(aerospace list-workspaces --all --format '%{workspace}' 2>/dev/null)

  # Get VISIBLE workspaces sorted by monitor-id (left → right)
  # Format: workspace|monitor-id|workspace-is-focused
  VISIBLE=$(aerospace list-workspaces --monitor all --visible \
    --format '%{workspace}|%{monitor-id}|%{workspace-is-focused}' 2>/dev/null \
    | sort -t'|' -k2 -n)

  # Build a list of visible workspace names for fast lookup
  VISIBLE_NAMES=""
  while IFS='|' read -r _ws _mid _focus; do
    [ -n "$_ws" ] && VISIBLE_NAMES="$VISIBLE_NAMES $_ws"
  done <<<"$VISIBLE"

  # Step 1: Hide all non-visible workspaces
  while IFS= read -r ws; do
    [ -z "$ws" ] && continue
    # Check if this workspace is in the visible list
    is_visible=false
    for v in $VISIBLE_NAMES; do
      [ "$v" = "$ws" ] && is_visible=true && break
    done
    if [ "$is_visible" = false ]; then
      sketchybar --set "space.$ws" drawing=off
    fi
  done <<<"$ALL_WS"

  # Step 2: Style and order visible workspaces (left → right)
  order_index=0
  while IFS='|' read -r ws mid focused; do
    [ -z "$ws" ] && continue

    if [ "$focused" = "true" ]; then
      # Focused workspace — accent highlight
      sketchybar --set "space.$ws" \
        drawing=on \
        background.drawing=$BG_ON \
        label.color=$ACCENT \
        label.font="IosevkaTerm NF:Bold:12.0" \
        background.border_color=$ACCENT
    else
      # Visible but not focused — dim
      sketchybar --set "space.$ws" \
        drawing=on \
        background.drawing=$BG_ON \
        label.color=$DIM \
        label.font="IosevkaTerm NF:Regular:12.0" \
        background.border_color=$ISLAND_BORDER
    fi

    # Reorder: move visible items to the left in monitor order
    # We move each visible item to be after the previous one
    if [ $order_index -eq 0 ]; then
      sketchybar --move "space.$ws" before separator_left
    else
      # After the previous visible item — we can't do "after" by name
      # easily, so we just rely on the shell to receive events.
      # Simplest: move all visible to before separator_left in order.
      sketchybar --move "space.$ws" before separator_left
    fi
    order_index=$((order_index + 1))
  done <<<"$VISIBLE"
}

# ── Initial update ─────────────────────────────────────────────────────────────
update_workspaces

# ── Subscribe to AeroSpace events ──────────────────────────────────────────────
aerospace subscribe --all 2>/dev/null | while read -r event; do
  event_type=$(echo "$event" | jq -r '._event // empty' 2>/dev/null)

  case "$event_type" in
    focused-workspace-changed|focused-monitor-changed|focus-changed)
      update_workspaces
      ;;
  esac
done
