#!/usr/bin/env bash
#
# install.sh — link this repository's home/ entries into $HOME.
#
# The repository root mirrors $HOME/.config, so everything outside home/ is
# already in place once the repository is cloned to ~/.config. This script only
# handles the files that live directly in $HOME.
#
# Behavior:
#   - Every file in home/ becomes a symlink at $HOME/<name>.
#   - home/ contains only files to link. Secret templates live in templates/,
#     which is deliberately outside home/ so nothing can link them by accident.
#   - An existing regular file is moved into a timestamped backup directory
#     before the symlink replaces it.
#   - Re-running is safe: an already-correct symlink is reported and skipped.
#
# Usage:
#   ./install.sh              link home/ into $HOME
#   ./install.sh --dry-run    print the plan without changing anything
#   ./install.sh --help       show this help
#
# Environment overrides:
#   DOTFILES_DIR          repository root (default: this script's directory)
#   DOTFILES_HOME_TARGET  target home directory (default: $HOME)
#
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${DOTFILES_DIR:-$SCRIPT_DIR}"
SRC_DIR="$REPO_ROOT/home"
TARGET_HOME="${DOTFILES_HOME_TARGET:-${HOME:-}}"

usage() {
  sed -n '2,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

DRY_RUN=0
case "${1:-}" in
  "")            ;;
  --dry-run|-n)  DRY_RUN=1 ;;
  --help|-h)     usage; exit 0 ;;
  *)
    printf 'install.sh: unknown option: %s\n\n' "$1" >&2
    usage >&2
    exit 2
    ;;
esac

if [[ -z "$TARGET_HOME" ]]; then
  printf 'install.sh: HOME is not set; use DOTFILES_HOME_TARGET\n' >&2
  exit 1
fi

if [[ ! -d "$SRC_DIR" ]]; then
  printf 'install.sh: %s does not exist\n' "$SRC_DIR" >&2
  exit 1
fi

if [[ "$REPO_ROOT" != "$TARGET_HOME/.config" ]]; then
  printf 'install.sh: note — repository is at %s, not %s/.config\n' \
    "$REPO_ROOT" "$TARGET_HOME" >&2
  printf 'install.sh: the ~/.config mirror only works in place; home/ links are unaffected.\n' >&2
fi

backup_dir="$TARGET_HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
linked=0
already=0
backed_up=0

run() {
  if (( DRY_RUN )); then
    printf '        would run: %s\n' "$*"
  else
    "$@"
  fi
}

for src in "$SRC_DIR"/.[!.]* "$SRC_DIR"/*; do
  [[ -e "$src" ]] || continue

  name="$(basename -- "$src")"
  dest="$TARGET_HOME/$name"

  if [[ -L "$dest" ]]; then
    current="$(readlink -- "$dest")"
    if [[ "$current" == "$src" ]]; then
      printf 'already linked  %s\n' "$dest"
      already=$((already + 1))
      continue
    fi
    printf 'relink          %s -> %s (was %s)\n' "$dest" "$src" "$current"
    run rm -f -- "$dest"
  elif [[ -e "$dest" ]]; then
    printf 'backup + link   %s (original saved)\n' "$dest"
    run mkdir -p -- "$backup_dir"
    run mv -- "$dest" "$backup_dir/$name"
    backed_up=$((backed_up + 1))
  else
    printf 'link            %s -> %s\n' "$dest" "$src"
  fi

  run ln -s -- "$src" "$dest"
  linked=$((linked + 1))
done

# ---------------------------------------------------------------------------
# Git hooks
# ---------------------------------------------------------------------------
# Point core.hooksPath at the tracked .githooks/ directory so a fresh clone gets
# the pre-commit secret scan. Setting this replaces .git/hooks entirely, which is
# fine here: it holds nothing but the .sample files Git ships.
hooks_report="not applicable"
if [[ -d "$REPO_ROOT/.githooks" ]] && git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  current="$(git -C "$REPO_ROOT" config --get core.hooksPath || true)"
  if [[ "$current" == ".githooks" ]]; then
    hooks_report="already set to .githooks"
  else
    printf 'git hooks       core.hooksPath -> .githooks\n'
    run git -C "$REPO_ROOT" config core.hooksPath .githooks
    if (( DRY_RUN )); then
      hooks_report="would set core.hooksPath to .githooks"
    else
      hooks_report=".githooks (pre-commit secret scan enabled)"
    fi
  fi
fi

printf '\nsummary: %d linked, %d already correct, %d original files backed up\n' \
  "$linked" "$already" "$backed_up"

printf 'git hooks: %s\n' "$hooks_report"

if (( backed_up > 0 )); then
  printf 'originals: %s\n' "$backup_dir"
fi

if (( DRY_RUN )); then
  printf 'dry run: nothing was changed\n'
else
  printf 'done. start a new shell, or run: exec zsh -l\n'
fi
