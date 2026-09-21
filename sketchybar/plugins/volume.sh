#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# The item has one script for every subscribed event: mouse.clicked arrives here too.
# Clicks belong to the click plugin, so hand the process over rather than running the
# readout for nothing. exec keeps the environment, including $BUTTON.
[ "$SENDER" = "mouse.clicked" ] && exec "$CONFIG_DIR/plugins/volume_click.sh"

# Volume - displays current volume level

RAW_VOLUME=$(osascript -e "output volume of (get volume settings)" 2>/dev/null)
MUTED=$(osascript -e "output muted of (get volume settings)" 2>/dev/null)

if [[ "$RAW_VOLUME" =~ ^[0-9]+$ ]]; then
  VOLUME="$RAW_VOLUME"
  LABEL="${VOLUME}%"
else
  VOLUME="0"
  LABEL="--"
fi

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
  COLOR=$RED
  ICON="$ICON_VOLUME_OFF"
else
  COLOR=$BLUE
  if [ "$VOLUME" -ge 66 ]; then
    ICON="$ICON_VOLUME_HIGH"
  elif [ "$VOLUME" -ge 33 ]; then
    ICON="$ICON_VOLUME_MEDIUM"
  else
    ICON="$ICON_VOLUME_LOW"
  fi
fi

sketchybar --set $NAME icon="$ICON" icon.color="$COLOR" label="$LABEL"
