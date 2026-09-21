#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# VOLUME CLICK — left click opens Sound settings, right click lists output devices
# ─────────────────────────────────────────────────────────────────────────────────
# Reached two ways:
#   1. routed here from plugins/volume.sh when the volume item receives mouse.clicked.
#      $BUTTON decides what happens: left opens the Sound pane, right toggles the popup.
#   2. invoked directly by a popup row's click_script, with VOLUME_DEVICE_INDEX set.
#      That is how a chosen device is switched.
#
# Popup rows pass the device INDEX, never its name. A device name is a system-supplied
# string and a row's click_script is a command line that sketchybar hands to a shell, so
# interpolating a name into it would let a name containing a quote, a backtick or $(...)
# run arbitrary code. An index is a plain integer and cannot carry anything.
#
# The index is resolved back to a name by re-enumerating the device list exactly the way
# the popup was built. If the output device list changes while the popup is open, the index
# points at a different device; the exposure is the seconds the popup stays open. Carrying
# the name safely instead would mean shell-quoting it with `printf '%q'` or encoding it,
# which makes the click_script harder to read for a smaller win.
#
# The device list needs SwitchAudioSource from the switchaudio-osx formula. Without it the
# popup explains that instead of silently doing nothing.
#
# Popup rows switch their own item background off. The popup already has a surface from the
# parent's popup.background, so each row would otherwise stack a second island on top of it.

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

SWITCH_AUDIO="$(command -v SwitchAudioSource)"

# Filled by enumerate_devices with the current output devices. Both the popup builder and
# the click handler go through this one function, so an index means the same thing on both
# sides: if only one of them skipped blank lines, the indices would silently drift apart.
OUTPUT_DEVICES=()

enumerate_devices() {
  local device
  OUTPUT_DEVICES=()
  while IFS= read -r device; do
    [ -z "$device" ] && continue
    OUTPUT_DEVICES[${#OUTPUT_DEVICES[@]}]="$device"
  done <<< "$("$SWITCH_AUDIO" -a -t output)"
}

open_sound_settings() {
  open -a 'System Preferences' /System/Library/PreferencePanes/Sound.prefPane
}

popup_is_open() {
  [ "$(sketchybar --query volume | jq -r '.popup.drawing')" = "on" ]
}

close_popup() {
  sketchybar --set volume popup.drawing=off
}

# Entry point 2: a popup row was clicked.
if [ -n "$VOLUME_DEVICE_INDEX" ]; then
  # Validated before the value is used as an array subscript.
  case "$VOLUME_DEVICE_INDEX" in
    ''|*[!0-9]*)
      echo "volume_click: refusing non-numeric device index: $VOLUME_DEVICE_INDEX" >&2
      exit 2
      ;;
  esac

  [ -n "$SWITCH_AUDIO" ] || exit 2

  enumerate_devices
  DEVICE="${OUTPUT_DEVICES[$VOLUME_DEVICE_INDEX]}"

  if [ -z "$DEVICE" ]; then
    echo "volume_click: no output device at index $VOLUME_DEVICE_INDEX (list changed?)" >&2
    exit 3
  fi

  "$SWITCH_AUDIO" -s "$DEVICE"
  close_popup
  exit 0
fi

# Everything below is entry point 1.
[ "$SENDER" = "mouse.clicked" ] || exit 0

if [ "$BUTTON" != "right" ]; then
  open_sound_settings
  exit 0
fi

# Right click toggles, so the popup can be dismissed the same way it was opened.
if popup_is_open; then
  close_popup
  exit 0
fi

if [ -z "$SWITCH_AUDIO" ]; then
  sketchybar --remove '/volume\.device\..*/' \
             --add item volume.device.none popup.volume \
             --set volume.device.none \
                    background.drawing=off \
                    label="switchaudio-osx no instalado" \
                    label.color=$DIM \
             --set volume popup.drawing=on
  exit 0
fi

enumerate_devices

CURRENT="$("$SWITCH_AUDIO" -t output -c)"

args=(--remove '/volume\.device\..*/')
COUNTER=0
while [ "$COUNTER" -lt "${#OUTPUT_DEVICES[@]}" ]; do
  device="${OUTPUT_DEVICES[$COUNTER]}"

  ICON=""
  COLOR=$DIM
  if [ "$device" = "$CURRENT" ]; then
    ICON="$ICON_CHECK"
    COLOR=$WHITE
  fi

  args+=(--add item "volume.device.$COUNTER" popup.volume
         --set "volume.device.$COUNTER" \
                background.drawing=off \
                icon="$ICON" \
                icon.color=$ACCENT_COLOR \
                label="$device" \
                label.color="$COLOR" \
                click_script="VOLUME_DEVICE_INDEX=$COUNTER $CONFIG_DIR/plugins/volume_click.sh")

  COUNTER=$((COUNTER + 1))
done

args+=(--set volume popup.drawing=on)
sketchybar -m "${args[@]}"
