#!/bin/bash

# SPACE/WORKSPACE INDICATOR — trigger-only handler
#
# Called by the aerospace_workspace_change trigger (fired by aerospace.toml hook)
# with FOCUSED_WORKSPACE=<full-ws-name> as env var. Compares the first digit of
# the focused workspace against this item's digit and styles accordingly.
# Items are label-only (no icon), so background lives under label.background.
# No daemon, no polling, no runtime aerospace queries here.

# ── Guard: only process when triggered by aerospace_workspace_change ────────────
# sketchybar --update triggers all scripts with FOCUSED_WORKSPACE empty, which
# would overwrite the active-workspace styling we set in sketchybarrc inline init.
# Exit early to preserve that initial state.
[ -z "$FOCUSED_WORKSPACE" ] && exit 0

# ── Colors (hardcoded; must match sketchybarrc) ────────────────────────────────
ACCENT=0xffe0c15a
DIM=0xff565f89
ISLAND_BG=0xff121620
ISLAND_BORDER=0xff263356

# Extract workspace name from item name (strip "space." prefix → "1-social")
WORKSPACE="${NAME#space.}"

# Extract the first digit of the focused workspace and of this item
FOCUSED_DIGIT="${FOCUSED_WORKSPACE:0:1}"
MY_DIGIT="${WORKSPACE:0:1}"

if [ "$MY_DIGIT" = "$FOCUSED_DIGIT" ]; then
  # This item is the active workspace — accent highlight
  sketchybar --set "$NAME" \
    drawing=on \
    label.background.drawing=on \
    label.background.color=$ISLAND_BG \
    label.background.border_color=$ACCENT \
    label.background.border_width=1 \
    label.color=$ACCENT \
    label.font="IosevkaTerm NF:Bold:12.0"
else
  # Inactive workspace — dim, no background
  sketchybar --set "$NAME" \
    label.background.drawing=off \
    label.color=$DIM \
    label.font="IosevkaTerm NF:Regular:12.0"
fi
