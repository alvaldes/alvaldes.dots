# #######################################################
# #   ZSH PROFILE - LOGIN SHELL CONFIGURATION           # #
# #######################################################

# --- setting alias ---
# lsd: Opciones atractivas y minimalistas
alias ll="lsd -l --group-dirs=first"
alias lla="lsd -la --group-dirs=first"
alias llt="lsd --tree --depth=2 --group-dirs=first"
alias llta="lsd -la --tree --depth=2 --group-dirs=first"

# #######################################################
# #   FZF & NAVIGATION                                  # #
# #######################################################
# fzf
alias fzfbat='fzf --preview="bat --theme=gruvbox-dark --color=always {}"'
alias fzfnvim='nvim $(fzf --preview="bat --theme=gruvbox-dark --color=always {}")'

# #######################################################
# #   EDITOR                                              # #
# #######################################################
# vim
alias v="nvim"

# #######################################################
# #   GIT                                                 # #
# #######################################################
# git
alias g="git"
alias glog="git log --graph --decorate --all --color=always"
alias gl="git log --graph --oneline --decorate --all --pretty=format:'%C(auto)%h %d %s %C(blue)%cr %C(green)(%an)'"
alias gst="git status -s"
alias gc="cz c"
alias gfetch="git fetch --all --prune"
alias gpull="git pull"
alias gpush="git push"
alias ghweb='open $(git config --get remote.origin.url | sed "s/git@github.com:/https:\/\/github.com\//" | sed "s/\.git$//")'

# #######################################################
# #   PYTHON                                              # #
# #######################################################
# python
alias py="python3"
alias pip="pip3"

# #######################################################
# #   PRODUCTIVITY & FUN                                  # #
# #######################################################
# extras
alias matrix="cmatrix -a -b -C cyan"
alias 'about'="clear && fastfetch"
alias '?'="fastfetch"
alias cl="clear"

# #######################################################
# #   AUTOCOMPLETION                                      # #
# #######################################################
# history setup
setopt SHARE_HISTORY
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt HIST_EXPIRE_DUPS_FIRST
# autocompletion using arrow keys (based on history)
# bindkey '\e[OA' history-search-backward
# bindkey '\e[OB' history-search-forward

# #######################################################
# #   NVM                                                   # #
# #######################################################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# #######################################################
# #   IDE                                                   # #
# #######################################################
# use idea .
export PATH="$PATH:/Applications/IntelliJ IDEA CE.app/Contents/MacOS"

# #######################################################
# #   HOMEBREW                                              # #
# #######################################################
eval "$(/opt/homebrew/bin/brew shellenv)"

# thefuck
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# #######################################################
# #   SDKMAN                                                  # #
# #######################################################
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# #######################################################
# #   TOOLBOX APP                                             # #
# #######################################################
# Added by Toolbox App
export PATH="$PATH:/Users/alvaldes/Library/Application Support/JetBrains/Toolbox/scripts"


# #######################################################
# #   PIPX & OPencode                                       # #
# #######################################################
# Created by `pipx` on 2025-03-01 06:21:07
export PATH="$PATH:/Users/alvaldes/.local/bin"
