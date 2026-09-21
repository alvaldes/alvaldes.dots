#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# VOLUME — output volume, read from macOS by plugins/volume.sh
# ─────────────────────────────────────────────────────────────────────────────────

volume=(
  icon="$ICON_VOLUME_HIGH"
  icon.font="$FONT_ICON_GLYPH"
  icon.color=$BLUE
  label.width=$METRIC_LABEL_W
  label.align=right
  label.padding_right=$PAD_LABEL_R_METRIC
  script="$PLUGIN_DIR/volume.sh"
  # The popup reuses the island surface on purpose: no blur and no shadow, so it
  # stays in the bar's existing visual language.
  popup.background.color=$POPUP_BG
  popup.background.border_color=$POPUP_BORDER
  popup.background.border_width=$ISLAND_BORDER_W
  popup.background.corner_radius=$ISLAND_R
)

sketchybar --add item volume right \
  --set volume "${volume[@]}" \
  --subscribe volume volume_change mouse.clicked
