# #######################################################
# #   ZSH ENV - READ BY EVERY ZSH, BEFORE ANYTHING ELSE  # #
# #######################################################
# zsh reads ~/.zshenv before it knows ZDOTDIR, so install.sh links
# ~/.zshenv -> ~/.config/zsh/.zshenv. Child shells inherit ZDOTDIR and read
# this same file again from there, so everything here must stay idempotent.

# Keep PATH entries unique: .zprofile and .zshrc both append to it, and a
# login shell runs both. -U keeps the first occurrence, so precedence holds.
typeset -U path PATH

# XDG base directories. An externally provided value wins.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# zsh reads .zprofile, .zshrc, and .zlogin from here.
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# History and caches go to XDG state/cache dirs; zsh does not create them.
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

# Python 3.13+ REPL history.
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"

# Stop macOS Terminal.app from writing ~/.zsh_sessions.
export SHELL_SESSIONS_DISABLE=1

# #######################################################
# #   TOOL LOCATIONS (XDG)                              # #
# #######################################################
# Tools that default to ~/.<name> but honor an env var. These only reach
# processes started from a shell: GUI apps launched from the Dock never read
# this file, so keep absolute ~/.<name> paths out of app configs.

# Runtimes and version managers (data: re-installable, but slow to rebuild).
export NVM_DIR="$XDG_DATA_HOME/nvm"
export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export CP_HOME_DIR="$XDG_DATA_HOME/cocoapods"
export GEM_HOME="$XDG_DATA_HOME/gem"
export IPYTHONDIR="$XDG_DATA_HOME/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"

# Caches (safe to delete at any time).
export npm_config_cache="$XDG_CACHE_HOME/npm"
export BUN_INSTALL_CACHE_DIR="$XDG_CACHE_HOME/bun"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export MPLCONFIGDIR="$XDG_CACHE_HOME/matplotlib"

# Bundler config can hold gem-server credentials, so it stays out of
# ~/.config, which is a public repository.
export BUNDLE_USER_CONFIG="$XDG_DATA_HOME/bundle/config"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle/plugin"

export PATH="$GEM_HOME/bin:$PATH"
