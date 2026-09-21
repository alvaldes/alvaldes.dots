#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# SPACE — focus indicator for one workspace digit
# ─────────────────────────────────────────────────────────────────────────────────
# Invoked by the aerospace_workspace_change trigger that aerospace.toml fires:
#     sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE
#
# $NAME is "space.<workspace>". Workspace names are bare digits, matching what
# `aerospace list-workspaces` reports, so an exact comparison is correct here.
#
# No runtime aerospace queries and no polling: the trigger drives everything.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/theme.sh"

# `sketchybar --update` runs every item script with FOCUSED_WORKSPACE unset. Bail out
# so the highlight painted inline by items/spaces.sh on load is not overwritten.
[ -z "$FOCUSED_WORKSPACE" ] && exit 0

WORKSPACE="${NAME#space.}"

if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" \
    label.background.drawing=on \
    label.background.color=$TRANSPARENT \
    label.background.border_color=$ACCENT_COLOR \
    label.background.border_width=$ISLAND_BORDER_W \
    label.color=$ACCENT_COLOR \
    label.font="$FONT_SPACE_ACTIVE"
else
  sketchybar --set "$NAME" \
    label.background.drawing=off \
    label.color=$DIM \
    label.font="$FONT_SPACE"
fi
