#  _________  _   _    ____ ___  _   _ _____ ___ ____
# |__  / ___|| | | |  / ___/ _ \| \ | |  ___|_ _/ ___|
#   / /\___ \| |_| | | |  | | | |  \| | |_   | | |  _
#  / /_ ___) |  _  | | |__| |_| | |\  |  _|  | | |_| |
# /____|____/|_| |_|  \____\___/|_| \_|_|   |___\____|

# Set environment for plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# check if already installed, if not install it - useful for new machines
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Add plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add snippets
zinit snippet OMZP::sudo

autoload -Uz compinit && compinit
zinit cdreplay -q

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath' 
zstyle ':completion:*' fzf-search-display true

export FZF_CTRL_T_OPTS="--preview 'batcat -n --color=always --line-range :500 {}'"
# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"export FZF_COMPLETION_TRIGGER='**'

# CTRL-Y to copy the command into clipboard using pbcopy
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | xsel -i -b)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

export FZF_COMPLETION_PATH_OPTS="--walker file,dir,follow,hidden"
export FZF_COMPLETION_DIR_OPTS="--walker dir,follow"

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin/"
export PATH="$PATH:$HOME/.cargo/bin/"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview "--preview 'batcat -n --color=always --line-range :500'" "$@" ;;
  esac
}

if [ -f /usr/bin/fastfetch ]; then
  fastfetch
fi

# Helpful aliases
alias  c='clear' 
alias ls='eza -lh --icons=always --color=always --sort=name --group-directories-first'  
alias la='eza -lha --icons=always --color=always --sort=name --group-directories-first'  
alias lt='eza --icons=always --color=always --tree --level=3' 
alias cd="z"
alias refresh="source ~/.zshrc"

alias rg="rg --color=always"
alias fd="fd --color=always"
alias gclone="gh repo clone"

alias v="nvim"
alias vim="nvim"

# nala
alias get="sudo nala install -y"
alias remove="sudo nala remove -y"
alias update="sudo nala update"

alias copy="xsel -i -b"
alias paste="xsel -o -b"

alias editzsh="nvim ~/.zshrc"
alias lg="lazygit"

# visual
alias open="xdg-open"
alias bat='batcat -p --color=always --theme="Dracula"'
alias q="exit"

alias ..='z ..'

alias startdocker="systemctl start docker"

# you may also use the following one
bindkey -s '^o' 'nvim $(fzf)\n'

# python environments
alias deac="deactivate"
function createnv() {
  envpath=$1
  python3 -m venv "$PWD/$envpath"
  cd "$PWD/$envpath"
}

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

export EDITOR="nvim"
export VISUAL="nvim"

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

setopt correct
setopt notify
setopt numericglobsort

unpack() {
  local arch="$1"
  local dest="$PWD"
  if [ -n "$2" ]; then
    dest="$2"
  fi
  if [ -f "$arch" ]; then
    case $arch in 
      *.tar.bz2) tar xvjf $arch -C "$dest" ;;
      *.tar.gz) tar xvzf $arch -C "$dest" ;;
      *.gz) gunzip $arch ;;
      *.rar) unrar x $arch "$dest";;
      *.tar) tar xvf $arch -C "$dest" ;;
      *.tar.xz) tar xvf $arch -C "$dest" ;;
      *.tbz2) tar xvjf $arch -C "$dest" ;;
      *.tgz) tar xvzf $arch -C "$dest" ;;
      *.zip) unzip $arch -d "$dest" ;;
      *) echo "Do not know how to extract '$arch' for now :(" ;;
    esac
  else
    echo "'$arch' is not a file!"
  fi
}
