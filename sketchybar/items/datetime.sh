#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# DATETIME — date and time
# ─────────────────────────────────────────────────────────────────────────────────

datetime=(
  icon="$ICON_CALENDAR"
  icon.font="$FONT_ICON_GLYPH"
  icon.color=$YELLOW
  label.padding_right=$PAD_LABEL_R_METRIC
  update_freq=30
  script="$PLUGIN_DIR/datetime.sh"
  click_script="open -a Calendar"
)

sketchybar --add item datetime right --set datetime "${datetime[@]}"
