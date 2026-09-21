#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# FRONT APP — the focused application, floating on the bar
# ─────────────────────────────────────────────────────────────────────────────────
# Fully transparent: this item draws no background at all, so the app name and its icon
# sit directly on the bar. `background.drawing=off` is how the item opts out, the same
# way items/spaces.sh and items/separator.sh do it — a transparent colour would leave the
# background drawn for nothing.
#
# label.color is white, not black. Black only worked because it sat on the green pill
# that has now been removed, and every other item on this bar uses white text.
#
# The app icon is painted into the icon's own background, never into the item
# background, so dropping the pill does not affect it.
#
# Height and corner radius are inherited from --default.
# ─────────────────────────────────────────────────────────────────────────────────

front_app=(
  label.font="$FONT_FRONT_APP"
  label.color=$BLACK
  label.padding_left=$PAD_LABEL_R_METRIC
  label.padding_right=$PAD_LABEL_R_METRIC
  label.max_chars=16
  scroll_texts=on
  background.drawing=off
  # The image is painted into the icon's own background (hence icon.background.drawing
  # and icon.background.image.drawing), not into the item background.
  icon.drawing=on
  icon.background.drawing=on
  icon.background.image.drawing=on
  icon.background.image.scale=$FRONT_APP_ICON_SCALE
  icon.width=$FRONT_APP_ICON_SIZE
  icon.background.height=$FRONT_APP_ICON_SIZE
  icon.background.corner_radius=4
  script="$PLUGIN_DIR/front_app.sh"
)

sketchybar --add item front_app left \
  --set front_app "${front_app[@]}" \
  --subscribe front_app front_app_switched
