#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# CPU — system CPU load, from plugins/cpu.sh
# ─────────────────────────────────────────────────────────────────────────────────

cpu=(
  icon="$ICON_CPU"
  icon.font="$FONT_ICON_GLYPH"
  icon.color=$RED
  label.width=$METRIC_LABEL_W
  label.align=right
  label.padding_right=$PAD_LABEL_R_METRIC
  update_freq=5
  script="$PLUGIN_DIR/cpu.sh"
  click_script="open -a 'Activity Monitor'"
)

sketchybar --add item cpu right --set cpu "${cpu[@]}"
