#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Mic - shows microphone status (on/off)

# Get mic input volume (0 = muted)
MIC_VOLUME=$(osascript -e "input volume of (get volume settings)")

if [ "$MIC_VOLUME" -eq 0 ]; then
  sketchybar --set $NAME icon="MIC" icon.color=$DIM label="OFF"
else
  sketchybar --set $NAME icon="MIC" icon.color=$RED label="ON"
fi
