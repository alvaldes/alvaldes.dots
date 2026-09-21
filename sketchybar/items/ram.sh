#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# RAM — memory pressure, from plugins/ram.sh
# ─────────────────────────────────────────────────────────────────────────────────

ram=(
  icon="$ICON_RAM"
  icon.font="$FONT_ICON_GLYPH"
  icon.color=$MAGENTA
  label.width=$METRIC_LABEL_W
  label.align=right
  label.padding_right=$PAD_LABEL_R_METRIC
  update_freq=10
  script="$PLUGIN_DIR/ram.sh"
  click_script="open -a 'Activity Monitor'"
)

sketchybar --add item ram right --set ram "${ram[@]}"
