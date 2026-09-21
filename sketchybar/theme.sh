#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# GENTLEMAN SKETCHYBAR — THEME TOKENS (fonts + geometry)
#
# Shared by sketchybarrc and by any plugin that has to re-apply a font or an island
# measurement at runtime. plugins/space.sh changes the workspace font on focus and is
# the reason this file exists: without it those font strings would be duplicated as
# literals inside a plugin, which is the exact drift this refactor removes.
#
# Colours live in colors.sh. Glyphs live in icons.sh.
# ─────────────────────────────────────────────────────────────────────────────────

# ── Fonts ─────────────────────────────────────────────────────────────────────
# Two real families, and the difference is NOT cosmetic:
#   "IosevkaTerm NF"  — proportional (IosevkaTermNerdFont-*)
#   "IosevkaTerm NFM" — monospaced   (IosevkaTermNerdFontMono-*)
#
# The item defaults (icon and label) are monospaced. Workspace digits, the front app,
# the separator and every right-hand metric icon are proportional.
FONT_UI="IosevkaTerm NF"
FONT_MONO="IosevkaTerm NFM"

FONT_ICON="$FONT_MONO:Bold:14.0"       # default item icon
FONT_ICON_GLYPH="$FONT_UI:Bold:14.0"   # every item glyph icon: battery + right-hand metrics
FONT_LABEL="$FONT_MONO:Medium:13.0"    # default item label and metric readouts
FONT_SPACE="$FONT_UI:Regular:12.0"     # inactive workspace digit
FONT_SPACE_ACTIVE="$FONT_UI:Bold:12.0" # focused workspace digit
FONT_FRONT_APP="$FONT_UI:Bold:12.0"
FONT_SEPARATOR="$FONT_UI:Bold:16.0"

# ── Geometry ──────────────────────────────────────────────────────────────────
ISLAND_H=20 # height of an island pill
ISLAND_R=12 # corner radius of an island pill
ISLAND_BORDER_W=1
ISLAND_BLUR=20
PAD_ITEM=6 # gap between neighbouring islands
PAD_ICON_L=10
PAD_ICON_R=4
PAD_LABEL_L=6
PAD_LABEL_R=8            # default label padding
PAD_LABEL_R_METRIC=10    # tighter right edge on the metric pills
METRIC_LABEL_W=40        # fixed width so the metric readouts line up vertically
SPACE_LABEL_PAD=8        # padding inside the small workspace pills
FRONT_APP_ICON_SIZE=15   # square box for the front app icon, in points
FRONT_APP_ICON_SCALE=0.6 # of FRONT_APP_ICON_SIZE, tuned by eye
