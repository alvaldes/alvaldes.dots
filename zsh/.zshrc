# #######################################################
# #   ZSH CONFIGURATION - SHELL RUNTIME CONFIGURATION   # #
# #######################################################

# #######################################################
# #   XDG BASE DIRS                                    # #
# #######################################################
# Must stay at the top: on macOS the XDG default for ConfigHome is
# ~/Library/Application Support, so XDG-aware Go tools (lazygit, carapace,
# anything using os.UserConfigDir or github.com/adrg/xdg) look there first
# and a stale file found there silently shadows the real one in ~/.config.
# Pin it to ~/.config before any of those tools is spawned. An externally
# provided value wins, so this stays overridable.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Created by Zap installer
# [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
# plug "zsh-users/zsh-autosuggestions"
# plug "zap-zsh/supercharge"
# plug "zap-zsh/zap-prompt"
# plug "zsh-users/zsh-syntax-highlighting"
# plug "MAHcodes/distro-prompt"

# #######################################################
# #   COMPLETION SYSTEM                                 # #
# #######################################################
# Load and initialise completion system
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# #######################################################
# #   RUST                                             # #
# #######################################################
export PATH="$HOME/.cargo/bin:$PATH"

# #######################################################
# #   EDITOR                                           # #
# #######################################################
# Set nvim as default editor for opencode and other tools
export EDITOR="nvim"
export VISUAL="nvim"

# #######################################################
# #   INTERACTIVE SESSIONS                             # #
# #######################################################
if [[ $- == *i* ]]; then
    # Commands to run in interactive sessions can go here
fi

# #######################################################
# #   CARAPACE                                           # #
# #######################################################
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# #######################################################
# #   SHELL AUTOCOMPLETE                               # #
# #######################################################
# source $(dirname $BREW_SHARE)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $(dirname /opt/homebrew/share)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(dirname /opt/homebrew/share)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Comentado para evitar conflictos con fzf y starship:
# source $(dirname /opt/homebrew/share)/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# #######################################################
# #   FZF INTEGRATION & SMART ARROW UP                  # #
# #######################################################

# 1. fzf itself is loaded once by `eval "$(fzf --zsh)"` in PRODUCTIVITY TOOLS;
# the widgets below resolve fzf-history-widget at keypress time.

# 2. Definir la función inteligente para la flecha arriba
# fzf-always-history activa el buscador fzf siempre
fzf-always-history() {
  # Llama al buscador de fzf conservando el texto actual como query inicial
  zle fzf-history-widget
}
zle -N fzf-always-history

# fzf-history-or-up activa el buscador fzf solo cuando no hay nada escrito, en caso contrario activa el por defecto de zsh
# fzf-history-or-up() {
#   if [ -z "$BUFFER" ]; then
#     zle fzf-history-widget
#   else
#     zle up-line-or-history
#   fi
# }
# zle -N fzf-history-or-up

# 3. Vincular todos los códigos de escape posibles para la flecha arriba
# (Cubre terminales estándar, tmux, iTerm2 y la terminal nativa de macOS)
bindkey '^[[A' fzf-always-history
bindkey '\e[A' fzf-always-history
bindkey '\e[OA' fzf-always-history

# #######################################################
# #   EDIT COMMAND LINE (Ctrl-X Ctrl-E)                # #
# #######################################################
# Open the current command buffer in $EDITOR/$VISUAL (nvim).
# The widget name is 'edit-command-line' with a hyphen: an '='
# there makes autoload look for a non-existent file and zle -N
# register a broken widget, so the real one stays unbound.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# #######################################################
# #   EXPORTED PATHS                                   # #
# #######################################################
export PROJECT_PATHS="$HOME/Developer"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="fd --type=f --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_OPTS="--prompt='Directory> ' --preview 'bat --color=always --style=numbers --line-range=:300 {}'"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# #######################################################
# #   STARSHIP PROMPT                                    # #
# #######################################################
# Starship
eval "$(starship init zsh)"

source "$ZDOTDIR/.zprofile"

# #######################################################
# #   PRODUCTIVITY TOOLS                                 # #
# #######################################################
eval "$(fzf --zsh)"
# Ctrl-O: pick a file with fzf and insert its path at the cursor (e.g. `vim ^O`)
bindkey '^O' fzf-file-widget

# Ctrl-F: jump to a project with fzf. Candidates: ~/.config, ghq repos,
# gwq worktrees, ~/Developer/local folders and subdirectories of $PWD.
# The cd runs through accept-line (like fzf's Alt-C) so precmd hooks,
# zoxide and the prompt all see the directory change.
fzf-project-widget() {
  setopt localoptions pipefail no_aliases 2>/dev/null
  local dir
  dir=$(
    {
      print -r -- "$HOME/.config"
      command ghq list -p 2>/dev/null
      command gwq list -g --json 2>/dev/null | jq -r '.[].path' 2>/dev/null
      print -rl -- "$HOME"/Developer/local/*(N/)
      print -rl -- "$PWD"/*(N/)
    } | awk '!seen[$0]++' | sed "s|^$HOME|~|" |
      fzf --prompt='Project> ' --scheme=path \
        --preview 'p={}; eza -1 --icons=always --group-directories-first "${p/#\~/$HOME}"'
  )
  if [[ -z $dir ]]; then
    zle reset-prompt
    return 0
  fi
  zle push-line
  BUFFER="builtin cd -- ${(q)dir/#\~/$HOME}"
  zle accept-line
}
zle -N fzf-project-widget
bindkey '^F' fzf-project-widget

# cpwd: copy the current directory to the clipboard, with $HOME shown as ~
cpwd() { print -rn -- "${PWD/#$HOME/~}" | pbcopy; }

# reload: start a fresh zsh instead of re-sourcing .zshrc, which would
# append PATH entries again and keep removed aliases/functions alive
alias reload='exec zsh'
eval "$(zoxide init zsh)"

# #######################################################
# #   YAZI SHELL WRAPPER                               # #
# #######################################################
# Wrapper oficial de yazi: abre el file manager y, al salir,
# hace cd al ultimo directorio en el que estabas si cambio.
function y() {
    local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
    command rm -f -- "$tmp"
}

# #######################################################
# #   DIRENV                                             # #
# #######################################################
# Carga/descarga variables de entorno por directorio (.envrc).
# Debe quedar despues del PATH definitivo para no perderlo al recargar entorno.
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# bun (BUN_INSTALL is exported in ~/.zshenv)
export PATH="$BUN_INSTALL/bin:$PATH"

# flutter
export PATH="$PATH:$HOME/Developer/github.com/flutter/flutter/bin"

# pnpm
export PNPM_HOME="/Users/alvaldes/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# python
# export PYTHONHOME=/opt/homebrew/Caskroom/miniconda/base

# # Ruta para que Python encuentre los módulos de scripting de Resolve
# export PYTHONPATH="/Library/Application Support/Blackmagic Design/DaVinci Resolve/Developer/Scripting/Modules:/opt/homebrew/Caskroom/miniconda/base/lib/python3.12"
# python end

# #######################################################
# #   BAT (TERMINAL THEME)                             # #
# #######################################################
# bat
export BAT_THEME=Nord

# #######################################################
# #   STANDARD PATHS                                     # #
# #######################################################
# Ensure standard system paths are included
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# #######################################################
# #   GOOGLE AI API KEY                                  # #
# #######################################################
# Set Google Generative AI API Key
export GOOGLE_GENERATIVE_AI_API_KEY=""

# #######################################################
# #   CUSTOM PATHS                                       # #
# #######################################################
# open hands the file to Launch Services, so Skim runs detached from the shell
alias skim='open -a Skim'

# #######################################################
# #   CONDA INIT                                         # #
# #######################################################
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# #######################################################
# #   PIPX & OPencode                                      # #
# #######################################################
# Created by `pipx` on 2025-03-01 06:21:07
export PATH="$PATH:/Users/alvaldes/.local/bin"

# opencode
export PATH=/Users/alvaldes/.opencode/bin:$PATH
export PATH="/opt/homebrew/bin:$PATH"

# Gentle Shell: command palette (AeroSpace ocupa alt+k y alt+shift+k)
export GENTLE_PI_COMMANDS_KEY="alt+p"

# gwq: completions plus the wrapper that lets `gwq cd` / `gwq add -s` change
# the current shell's directory (needs cd.launch_shell = false in gwq config)
if command -v gwq >/dev/null 2>&1; then source <(gwq completion zsh); fi
