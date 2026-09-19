#!/usr/bin/env bash
#
# fetch-zellij-plugins.sh — restore the Zellij plugins this configuration needs.
#
# zellij/config.kdl and every zellij/layouts/*.kdl reference the plugins through
# local `file:` paths, so Zellij never downloads them. They are not versioned
# here either: they are vendored binary artifacts of the upstream Gentleman.Dots
# installer, and tracking them added ~5 MB that changed on every release.
#
# This script fetches them from the upstream repository and verifies each file
# against a pinned SHA-256 before installing it.
#
# Usage:
#   ./scripts/fetch-zellij-plugins.sh              install missing plugins
#   ./scripts/fetch-zellij-plugins.sh --force      re-download even if present
#   ./scripts/fetch-zellij-plugins.sh --dry-run    show what would happen
#   ./scripts/fetch-zellij-plugins.sh --help
#
# Environment overrides:
#   ZELLIJ_PLUGIN_DIR   install directory (default: $HOME/.config/zellij/plugins)
#
set -euo pipefail

UPSTREAM_BASE="https://raw.githubusercontent.com/Gentleman-Programming/Gentleman.Dots/main/GentlemanZellij/zellij/plugins"

PLUGIN_DIR="${ZELLIJ_PLUGIN_DIR:-${HOME:-}/.config/zellij/plugins}"

# Pinned integrity digests, verified byte-identical to the files previously
# tracked in this repository. Update them together with any intentional bump.
PLUGINS=(
  "zjstatus.wasm:e006901223524239db618021e4cc5d17f82dc4bfae5432895ba41f03f13861ff"
  "zellij_forgot.wasm:31194145519dbdc128685b456f970374378fa19fc9da742fbe4a321bace449db"
)

DRY_RUN=0
FORCE=0

usage() {
  sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while (( $# > 0 )); do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --force|-f)   FORCE=1 ;;
    --help|-h)    usage; exit 0 ;;
    *) printf 'fetch-zellij-plugins.sh: unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

if [[ -z "$PLUGIN_DIR" || "$PLUGIN_DIR" == "/.config/zellij/plugins" ]]; then
  printf 'fetch-zellij-plugins.sh: HOME is not set; use ZELLIJ_PLUGIN_DIR\n' >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  printf 'fetch-zellij-plugins.sh: curl is required\n' >&2
  exit 1
fi

if command -v shasum >/dev/null 2>&1; then
  sha256() { shasum -a 256 "$1" | cut -d' ' -f1; }
elif command -v sha256sum >/dev/null 2>&1; then
  sha256() { sha256sum "$1" | cut -d' ' -f1; }
else
  printf 'fetch-zellij-plugins.sh: neither shasum nor sha256sum is available\n' >&2
  exit 1
fi

printf 'target: %s\n\n' "$PLUGIN_DIR"

installed=0
skipped=0

for entry in "${PLUGINS[@]}"; do
  name="${entry%%:*}"
  want="${entry##*:}"
  dest="$PLUGIN_DIR/$name"

  if [[ -f "$dest" ]] && (( ! FORCE )); then
    have="$(sha256 "$dest")"
    if [[ "$have" == "$want" ]]; then
      printf 'ok          %s (already current)\n' "$name"
      skipped=$((skipped + 1))
      continue
    fi
    printf 'stale       %s (digest differs, re-downloading)\n' "$name"
  fi

  if (( DRY_RUN )); then
    printf 'would fetch %s\n' "$name"
    continue
  fi

  mkdir -p -- "$PLUGIN_DIR"
  tmp="$(mktemp "${TMPDIR:-/tmp}/$name.XXXXXX")"
  # shellcheck disable=SC2064
  trap "rm -f -- '$tmp'" EXIT

  printf 'fetch       %s\n' "$name"
  if ! curl -fsSL "$UPSTREAM_BASE/$name" -o "$tmp"; then
    printf 'error: download failed for %s\n' "$name" >&2
    exit 1
  fi

  have="$(sha256 "$tmp")"
  if [[ "$have" != "$want" ]]; then
    printf 'error: digest mismatch for %s\n  expected %s\n  got      %s\n' \
      "$name" "$want" "$have" >&2
    printf 'The upstream file changed. Update the pinned digest in this script only after reviewing the diff.\n' >&2
    exit 1
  fi

  mv -- "$tmp" "$dest"
  trap - EXIT
  printf 'installed   %s (digest verified)\n' "$name"
  installed=$((installed + 1))
done

printf '\nsummary: %d installed, %d already current\n' "$installed" "$skipped"

if (( DRY_RUN )); then
  printf 'dry run: nothing was changed\n'
elif (( installed > 0 )); then
  printf 'restart Zellij for the plugins to load.\n'
fi
