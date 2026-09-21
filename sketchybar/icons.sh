#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# GENTLEMAN SKETCHYBAR — ICON GLYPHS
#
# Single source of truth for every glyph used in this setup. Both sketchybarrc
# and every script under items/ and plugins/ source this file.
#
# Every codepoint below was verified to exist in the installed
# IosevkaTermNerdFontMono-Regular.ttf by reading its cmap and post tables, and the
# Nerd Font name in each comment was read from that same post table.
#
# Do not paste glyphs from a cheat sheet by hand: a codepoint absent from the
# installed font renders as a tofu box. Verify before adding, and keep the comment
# naming the source glyph so a future change can be checked.
# ─────────────────────────────────────────────────────────────────────────────────

# System metrics
export ICON_CPU=""                   # U+F2DB  fa-microchip
export ICON_GPU="󰢮"                   # U+F08AE  md-expansion_card
export ICON_RAM="󰍛"                   # U+F035B  md-memory
export ICON_CALENDAR="󰃭"              # U+F00ED  md-calendar
export ICON_MEETING="󰃰"               # U+F00F0  md-calendar_clock
export ICON_VOLUME_HIGH="󰕾"           # U+F057E  md-volume_high
export ICON_VOLUME_MEDIUM="󰖀"         # U+F0580  md-volume_medium
export ICON_VOLUME_LOW="󰕿"            # U+F057F  md-volume_low
export ICON_VOLUME_OFF="󰖁"            # U+F0581  md-volume_off
export ICON_SPEAKER="󰓃"               # U+F04C3  md-speaker
export ICON_CHECK="󰄬"                 # U+F012C  md-check

# Battery level
export ICON_BATTERY="󰁹"               # U+F0079  md-battery
export ICON_BATTERY_80="󰂁"            # U+F0081  md-battery_80
export ICON_BATTERY_60="󰁿"            # U+F007F  md-battery_60
export ICON_BATTERY_30="󰁼"            # U+F007C  md-battery_30
export ICON_BATTERY_ALERT="󰂃"         # U+F0083  md-battery_alert
export ICON_BATTERY_CHARGING="󰂄"      # U+F0084  md-battery_charging

# Window layout state
export ICON_WINDOW_TILED="󰋁"          # U+F02C1  md-grid
export ICON_WINDOW_FLOATING="󰉈"       # U+F0248  md-flip_to_front
export ICON_WINDOW_ACCORDION="󰌨"      # U+F0328  md-layers
export ICON_WINDOW_HIDDEN="󰈉"         # U+F0209  md-eye_off

# Volume bands used by plugins/volume.sh
#   ICON_VOLUME_HIGH    66-100%
#   ICON_VOLUME_MEDIUM  33-65%
#   ICON_VOLUME_LOW     1-32%
#   ICON_VOLUME_OFF     0% or muted

# Battery bands used by plugins/battery.sh
#   ICON_BATTERY        90-100%   (md-battery)
#   ICON_BATTERY_80     60-89%    (md-battery_80)
#   ICON_BATTERY_60     30-59%    (md-battery_60)
#   ICON_BATTERY_30     10-29%    (md-battery_30)
#   ICON_BATTERY_ALERT  0-9%      (md-battery_alert)
#   ICON_BATTERY_CHARGING  charging

# Window layouts, from aerospace %{window-layout}
#   ICON_WINDOW_TILED     h_tiles / v_tiles
#   ICON_WINDOW_FLOATING  floating
#   ICON_WINDOW_ACCORDION v_accordion / h_accordion
#   ICON_WINDOW_HIDDEN    macos_native_window_of_a_hidden_app
