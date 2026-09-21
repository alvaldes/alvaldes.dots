#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# CPU - ps-based (19ms) instead of top (500ms)

NCPU=$(sysctl -n hw.ncpu)
CPU=$(ps -A -o %cpu | awk -v n="$NCPU" '{s+=$1} END {v=s/n; if(v>100)v=100; printf "%d",v}')

if [ "$CPU" -ge 80 ]; then
  COLOR=$RED
elif [ "$CPU" -ge 50 ]; then
  COLOR=$YELLOW
else
  COLOR=$CYAN
fi

sketchybar --set $NAME icon.color="$COLOR" label="${CPU}%"
