#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Battery - displays battery percentage with dynamic icon and color

# `head -1` keeps this deterministic if the machine ever reports more than one percentage,
# e.g. an external battery alongside the internal one. `tr -d '%'` is equivalent to the
# `cut -d% -f1` it replaces, and the POSIX character class replaces a `\d` that happens to
# work with this build of grep but is not part of the standard.
PERCENTAGE=$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
CHARGING=$(pmset -g batt | grep 'AC Power')

# Covers both "no battery reported" (a desktop Mac) and "the value did not parse". Only the
# empty case was handled before, so a non-numeric value reached the -ge comparisons below,
# printed "integer expression expected", and then fell through to the critical-red branch
# with the garbage as the label. Neither case is worth rendering, so the item is hidden.
case "$PERCENTAGE" in
  ''|*[!0-9]*)
    sketchybar --set "$NAME" drawing=off
    exit 0
    ;;
esac

# Determine icon and color based on level
if [ -n "$CHARGING" ]; then
  ICON="$ICON_BATTERY_CHARGING"
  COLOR=$ACCENT_COLOR
elif [ "$PERCENTAGE" -ge 80 ]; then
  ICON="$ICON_BATTERY"
  COLOR=$GREEN
elif [ "$PERCENTAGE" -ge 60 ]; then
  ICON="$ICON_BATTERY_80"
  COLOR=$GREEN
elif [ "$PERCENTAGE" -ge 40 ]; then
  ICON="$ICON_BATTERY_60"
  COLOR=$YELLOW
elif [ "$PERCENTAGE" -ge 20 ]; then
  ICON="$ICON_BATTERY_30"
  COLOR=$RED
else
  ICON="$ICON_BATTERY_ALERT"
  COLOR=$RED
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
