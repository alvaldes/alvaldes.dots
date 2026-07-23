#!/bin/bash

# SPACE/WORKSPACE INDICATOR — fallback updater
# The aerospace_events.sh daemon handles the real-time updates.
# This script runs periodically (via update_freq) as a safety net
# to catch any state changes the daemon might miss.

ACCENT=0xffe0c15a
DIM=0xff565f89
ISLAND_BORDER=0xff263356

# Extract workspace name from item name (strip "space." prefix)
WORKSPACE="${NAME#space.}"

# Query AeroSpace for this workspace's status
STATUS=$(aerospace list-workspaces --monitor all \
  --format '%{workspace}|%{workspace-is-visible}|%{workspace-is-focused}' 2>/dev/null \
  | grep "^${WORKSPACE}|")

if [ -n "$STATUS" ]; then
  VISIBLE=$(echo "$STATUS" | cut -d'|' -f2)
  FOCUSED=$(echo "$STATUS" | cut -d'|' -f3)

  if [ "$FOCUSED" = "true" ]; then
    sketchybar --set "$NAME" \
      drawing=on \
      background.drawing=on \
      label.color=$ACCENT \
      label.font="IosevkaTerm NF:Bold:12.0" \
      background.border_color=$ACCENT
  elif [ "$VISIBLE" = "true" ]; then
    sketchybar --set "$NAME" \
      drawing=on \
      background.drawing=on \
      label.color=$DIM \
      label.font="IosevkaTerm NF:Regular:12.0" \
      background.border_color=$ISLAND_BORDER
  else
    sketchybar --set "$NAME" drawing=off
  fi
fi
