# Created by Zap installer
# [ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
# plug "zsh-users/zsh-autosuggestions"
# plug "zap-zsh/supercharge"
# plug "zap-zsh/zap-prompt"
# plug "zsh-users/zsh-syntax-highlighting"
# plug "MAHcodes/distro-prompt"

# Load and initialise completion system
autoload -Uz compinit
compinit

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.cargo/bin:$PATH"

if [[ $- == *i* ]]; then
    # Commands to run in interactive sessions can go here
fi

BREW_BIN="/opt/homebrew/bin/"
BREW_SHARE="/opt/homebrew/share/"

# Usar la variable BREW_BIN donde se necesite
eval "$($BREW_BIN/brew shellenv)"

source $(dirname $BREW_SHARE)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $(dirname $BREW_SHARE)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(dirname $BREW_SHARE)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(dirname $BREW_SHARE)/share/powerlevel10k/powerlevel10k.zsh-theme
source $(dirname $BREW_SHARE)/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

export PROJECT_PATHS="/home/alvaldes/Developer"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exlude .git"

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
alias zj=start_zellij
alias zi='zellij a --index 0'

#plugins
plugins=(
  command-not-found
)

source ~/.zprofile
# source $ZSH/oh-my-zsh.sh

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
# eval "$(starship init zsh)"

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

# Ensure standard system paths are included
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Set Google Generative AI API Key
export GOOGLE_GENERATIVE_AI_API_KEY=""

export PATH="/Library/TeX/texbin:$PATH"

# Add custom paths
export PATH="$HOME/.console-ninja/.bin:$PATH"

PATH=~/.console-ninja/.bin:$PATH
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
alias skim='/Applications/Skim.app/Contents/MacOS/Skim'

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

export PATH=$PATH:/usr/bin

# Created by `pipx` on 2025-03-01 06:21:07
export PATH="$PATH:/Users/alvaldes/.local/bin"
