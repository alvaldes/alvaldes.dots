# #######################################################
# #   ZSH CONFIGURATION - SHELL RUNTIME CONFIGURATION   # #
# #######################################################

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
compinit

# #######################################################
# #   POWERLEVEL10K INSTANT PROMPT                     # #
# #######################################################
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# to use this uncomment from here
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
#
# source $(dirname $BREW_SHARE)/share/powerlevel10k/powerlevel10k.zsh-theme
# export ZSH="$HOME/.oh-my-zsh"
# to this -- p10k

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

# 1. Carga tradicional compatible de FZF en macOS
if [ -d "/opt/homebrew/opt/fzf" ]; then
  source "/opt/homebrew/opt/fzf/shell/completion.zsh"
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
elif [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
fi

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
# #   EXPORTED PATHS                                   # #
# #######################################################
export PROJECT_PATHS="/home/alvaldes/Developer"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exlude .git"

# #######################################################
# #   STARSHIP PROMPT                                    # #
# #######################################################
# Starship
eval "$(starship init zsh)"

# #######################################################
# #   ZELLIJ                                           # #
# #######################################################

WM_VAR="/$ZELLIJ"
# TMUX or ZELLIJ
WM_CMD="zellij"
# tmux or zellij

function start_if_needed() {
    if [[ $- == *i* ]] && [[ -z "${WM_VAR#/}" ]] && [[ -t 1 ]]; then
        exec $WM_CMD
    fi
}

# Definir la función start_zellij
start_zellij() {
  # Verificar si no estamos ya dentro de una sesión de Zellij
  if [[ -z "$ZELLIJ" ]]; then
    # Si la variable ZELLIJ_AUTO_ATTACH está establecida en 'true', adjuntar a una sesión existente
    if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then
      zellij attach -c
    else
      # De lo contrario, iniciar una nueva sesión de Zellij
      zellij
    fi

    # Si la variable ZELLIJ_AUTO_EXIT está establecida en 'true', salir del shell al salir de Zellij
    if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then
      exit
    fi
  fi
}

# alias
alias ze=start_zellij
alias zj='zellij a --index 0'

# #######################################################
# #   PLUGINS                                          # #
# #######################################################
#plugins
plugins=(
  command-not-found
)

source ~/.zprofile
# source $ZSH/oh-my-zsh.sh

# #######################################################
# #   PRODUCTIVITY TOOLS                                 # #
# #######################################################
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bun completions
[ -s "/Users/alvaldes/.bun/_bun" ] && source "/Users/alvaldes/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# flutter
export PATH="$PATH:/Users/alvaldes/Developer/flutter/bin"

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
# Add custom paths
export PATH="$HOME/.console-ninja/.bin:$PATH"

PATH=~/.console-ninja/.bin:$PATH
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
alias skim='/Applications/Skim.app/Contents/MacOS/Skim'

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
