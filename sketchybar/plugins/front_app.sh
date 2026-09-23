#!/bin/bash

# ─────────────────────────────────────────────────────────────────────────────────
# FRONT APP — app name and app icon
# ─────────────────────────────────────────────────────────────────────────────────
# The item subscribes to front_app_switched only. There is no floating indication here
# any more, and this file no longer needs colors.sh or theme.sh: it applies no style of
# its own.

# The icon is requested as `app.<bundle id>`, never as `app.<app name>`. SketchyBar
# resolves the name form by scanning runningApplications for the first localizedName
# match, and a helper or widget process can win that race: "Podcasts" resolves to
# PodcastsWidget (com.apple.podcasts.widget), whose bundle id has no application URL,
# so SketchyBar ends up calling iconForFile:(nil) and paints the generic document
# icon. A bundle id goes straight through LaunchServices and cannot be shadowed.
if [ "$SENDER" = "front_app_switched" ]; then
  bundle_id="$(lsappinfo info -only bundleID "$(lsappinfo front 2>/dev/null)" 2>/dev/null \
    | sed -n 's/.*bundleID="\([^"]*\)".*/\1/p')"

  # A process without a bundle id reports `bundleID=[ NULL ]`, which the pattern above
  # does not match. The item then falls back to the name form instead of no icon.
  sketchybar --set "$NAME" label="$INFO" icon.background.image="app.${bundle_id:-$INFO}"
fi
