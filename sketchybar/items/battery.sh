#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# BATTERY — rightmost island
# ─────────────────────────────────────────────────────────────────────────────────
# Battery uses the proportional family at the shared glyph size, like its sibling metrics.

battery=(
  icon.font="$FONT_ICON_GLYPH"
  icon.color=$GREEN
  label.width=$METRIC_LABEL_W
  label.align=right
  label.padding_right=$PAD_LABEL_R_METRIC
  update_freq=60
  script="$PLUGIN_DIR/battery.sh"
  click_script="open -a 'System Preferences' /System/Library/PreferencePanes/Battery.prefPane"
)

sketchybar --add item battery right \
  --set battery "${battery[@]}" \
  --subscribe battery system_woke power_source_change
