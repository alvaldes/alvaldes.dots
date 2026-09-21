#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# GENTLEMAN SKETCHYBAR — COLOR PALETTE
#
# Single source of truth for every colour in this setup. Both sketchybarrc and
# every script under items/ and plugins/ source this file.
#
# Do not hardcode ARGB hex anywhere else. sketchybar takes colours as 0xAARRGGBB
# (alpha first, so 0xff<rgb> is opaque).
#
# Palette matches the Ghostty/Neovim theme of this dotfiles repo.
# ─────────────────────────────────────────────────────────────────────────────────

# Base palette
export BLACK=0xff06080f
export WHITE=0xfff3f6f9
export RED=0xffcb7c94
export GREEN=0xffb7cc85
export YELLOW=0xffffe066
export ORANGE=0xfffff7b1
export BLUE=0xff7fb4ca
export MAGENTA=0xffff8dd7
export CYAN=0xff7aa89f
export TRANSPARENT=0x00000000

# Island surface — the floating pill every item sits on
export ISLAND_BG=0x16000000
export ISLAND_BORDER=0x18ffffff

# Accent for the active workspace and the workspace separator
export ACCENT_COLOR=0xffe0c15a

# Muted foreground for inactive workspaces and placeholder labels
export DIM=0xff565f89

# ─────────────────────────────────────────────────────────────────────────────────
# Semantic aliases — prefer these in items/ and plugins/ so a palette change above
# propagates without touching item code.
# ─────────────────────────────────────────────────────────────────────────────────
export BAR_COLOR=$TRANSPARENT
export POPUP_BG=$ISLAND_BG
export POPUP_BORDER=$ISLAND_BORDER
