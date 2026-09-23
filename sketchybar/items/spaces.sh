#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# WORKSPACES (AEROSPACE)
# ─────────────────────────────────────────────────────────────────────────────────
# AeroSpace's `persistent-workspaces` is the source of truth for which workspaces
# exist. The array below must mirror it, and it is also what sets the ORDER of the
# digits in the bar.
#
# aerospace.toml declares:
#     persistent-workspaces = ["1", "2", "3", "4", "5", "8", "9", "0"]
#
# The names must be bare digits, exactly as `aerospace list-workspaces` reports them.
# If they are not, `click_script="aerospace workspace $ws"` resolves against a
# workspace that does not exist and the click silently does nothing.
#
# The bar is deliberately NOT derived from `aerospace list-workspaces --all`: that
# command returns workspaces in its own order, which would scramble the bar. An
# explicit array keeps existence and display order as separate concerns.
#
# aerospace.toml fires this trigger on every workspace change:
#     sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE
# Every space item subscribes to it, and plugins/space.sh styles the focused one.
# Custom events must be declared with --add event before items can subscribe.
# ─────────────────────────────────────────────────────────────────────────────────

sketchybar --add event aerospace_workspace_change

WORKSPACES=("1" "2" "3" "4" "5" "8" "9" "0")

SPACE=(
  icon.drawing=off
  label.font="$FONT_SPACE"
  label.color=$DIM
  label.padding_left=$SPACE_LABEL_PAD
  label.padding_right=$SPACE_LABEL_PAD
  padding_left=2
  padding_right=2
  # Spaces are label-only. The item background is switched off deliberately: the only
  # rectangle that should be visible is label.background on the focused workspace.
  # Leaving the item background on stacks a second, taller pill behind every digit.
  background.drawing=off
  # Focus indicator, toggled by plugins/space.sh.
  label.background.color=$TRANSPARENT
  label.background.border_color=$ISLAND_BORDER
  label.background.border_width=$ISLAND_BORDER_W
  label.background.corner_radius=$ISLAND_R
  label.background.height=$ISLAND_H
  label.background.drawing=off
  script="$PLUGIN_DIR/space.sh"
)

for ws in "${WORKSPACES[@]}"; do
  sketchybar --add item "space.$ws" left \
    --set "space.$ws" "${SPACE[@]}" \
    label="$ws" \
    click_script="aerospace workspace $ws" \
    --subscribe "space.$ws" aerospace_workspace_change
done

# ─────────────────────────────────────────────────────────────────────────────────
# INITIAL FOCUS
#
# Paint the focused workspace directly instead of waiting for the first trigger. The
# trigger cannot cover this: `sketchybar --update` runs every item script with an
# empty FOCUSED_WORKSPACE, which plugins/space.sh treats as "leave it alone", so
# without this block the bar would come up with nothing highlighted.
# ─────────────────────────────────────────────────────────────────────────────────
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)

if [ -n "$FOCUSED_WORKSPACE" ]; then
  # Only the label colour and font are painted here. The island edge is deliberately
  # left at the neutral $ISLAND_BORDER that the SPACE array sets, so the focused
  # workspace looks the same however it took focus: on a cold start (this block) or
  # after a switch (plugins/space.sh). Painting $ACCENT_COLOR here is what made the
  # first focused workspace the only one with a gold edge.
  sketchybar --set "space.$FOCUSED_WORKSPACE" \
    label.background.drawing=on \
    label.color=$ACCENT_COLOR \
    label.font="$FONT_SPACE_ACTIVE"
fi
