#!/usr/bin/env bash
#
# install.sh — wire this repository into $HOME.
#
# The repository root mirrors $HOME/.config, so everything is already in place
# once the repository is cloned to ~/.config. This script only handles the few
# files that tools look up directly in $HOME.
#
# Behavior:
#   - Each entry in LINKS becomes a symlink at $HOME/<name> pointing into the
#     repository (for example ~/.zshenv -> ~/.config/zsh/.zshenv).
#   - ~/.hushlogin is created as an empty file. login(1) only checks that it
#     exists, so there is nothing to version.
#   - An existing regular file is moved into a timestamped backup directory
#     before the symlink replaces it.
#   - Re-running is safe: an already-correct symlink is reported and skipped.
#   - A dangling symlink in $HOME that points into the repository (a file that
#     has since moved) is removed.
#
# Usage:
#   ./install.sh              wire the repository into $HOME
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
TARGET_HOME="${DOTFILES_HOME_TARGET:-${HOME:-}}"

# <name in $HOME>:<path relative to the repository root>
LINKS=(
  ".zshenv:zsh/.zshenv"
)

usage() {
  sed -n '2,28p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
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

if [[ "$REPO_ROOT" != "$TARGET_HOME/.config" ]]; then
  printf 'install.sh: note — repository is at %s, not %s/.config\n' \
    "$REPO_ROOT" "$TARGET_HOME" >&2
  printf 'install.sh: the ~/.config mirror only works in place; $HOME links are unaffected.\n' >&2
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

# Remove dangling links left behind by files that moved inside the repository
# (for example ~/.zshenv from when it lived in home/). Only links that point
# into the repository and whose target no longer exists are touched.
pruned=0
for dest in "$TARGET_HOME"/.[!.]* "$TARGET_HOME"/*; do
  [[ -L "$dest" && ! -e "$dest" ]] || continue
  current="$(readlink -- "$dest")"
  [[ "$current" == "$REPO_ROOT"/* ]] || continue
  printf 'prune           %s (target %s is gone)\n' "$dest" "$current"
  run rm -f -- "$dest"
  pruned=$((pruned + 1))
done

for entry in "${LINKS[@]}"; do
  name="${entry%%:*}"
  src="$REPO_ROOT/${entry#*:}"
  dest="$TARGET_HOME/$name"

  if [[ ! -e "$src" ]]; then
    printf 'install.sh: %s does not exist\n' "$src" >&2
    exit 1
  fi

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

# Silence the "Last login" banner. Any existing file or link already works.
if [[ -e "$TARGET_HOME/.hushlogin" ]]; then
  printf 'already present %s\n' "$TARGET_HOME/.hushlogin"
else
  printf 'create          %s\n' "$TARGET_HOME/.hushlogin"
  run touch -- "$TARGET_HOME/.hushlogin"
fi

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

printf '\nsummary: %d linked, %d already correct, %d original files backed up, %d stale links pruned\n' \
  "$linked" "$already" "$backed_up" "$pruned"

printf 'git hooks: %s\n' "$hooks_report"

if (( backed_up > 0 )); then
  printf 'originals: %s\n' "$backup_dir"
fi

if (( DRY_RUN )); then
  printf 'dry run: nothing was changed\n'
else
  printf 'done. start a new shell, or run: exec zsh -l\n'
fi
