#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# SEPARATOR — visual divider between the workspaces and the front app
# ─────────────────────────────────────────────────────────────────────────────────

sketchybar --add item separator_left left \
  --set separator_left \
    icon=">" \
    icon.color=$ACCENT_COLOR \
    icon.font="$FONT_SEPARATOR" \
    icon.padding_left=$SPACE_LABEL_PAD \
    icon.padding_right=$SPACE_LABEL_PAD \
    background.drawing=off \
    label.drawing=off
