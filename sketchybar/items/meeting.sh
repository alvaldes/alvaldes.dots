#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# MEETING (next calendar event) — PARKED, NOT LOADED
# ─────────────────────────────────────────────────────────────────────────────────
# This definition is deliberately NOT sourced by sketchybarrc: the matching line is
# commented out there. Enable both together.
#
# plugins/meeting.sh is kept for the same reason. It now uses the same Nerd Font glyph
# and glyph font size as the other right-hand metrics.

meeting=(
  icon="$ICON_MEETING"
  icon.font="$FONT_ICON_GLYPH"
  icon.color=$YELLOW
  label.max_chars=12
  scroll_texts=on
  label.padding_right=$PAD_LABEL_R_METRIC
  update_freq=60
  script="$PLUGIN_DIR/meeting.sh"
  click_script="open -a Calendar"
)

sketchybar --add item meeting right --set meeting "${meeting[@]}"
