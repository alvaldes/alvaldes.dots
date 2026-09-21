#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# GPU — Apple Silicon GPU utilisation, from plugins/gpu.sh
# ─────────────────────────────────────────────────────────────────────────────────

gpu=(
  icon="$ICON_GPU"
  icon.font="$FONT_ICON_GLYPH"
  icon.color=$ORANGE
  label.width=$METRIC_LABEL_W
  label.align=right
  label.padding_right=$PAD_LABEL_R_METRIC
  update_freq=10
  script="$PLUGIN_DIR/gpu.sh"
  click_script="open -a 'Activity Monitor'"
)

sketchybar --add item gpu right --set gpu "${gpu[@]}"
