# Return if not an interactive shell
[[ "$-" != *i* ]] && return

# User bin
export PATH=~/bin:$PATH

# Golang
export GOPATH=~/go

export PATH=$PATH:$GOPATH/bin:/opt/google-cloud-sdk/bin

# Do not capture ^Q or ^S
stty start undef
stty stop undef

# Do not save history for less
export LESSHISTFILE="/dev/null"

# Start blink, bold, reverse, standout, underline
export LESS_TERMCAP_mb="$(tput bold; tput setaf 1)"
export LESS_TERMCAP_md="$(tput bold; tput setaf 1)"
export LESS_TERMCAP_mr="$(tput bold; tput setaf 1)"
export LESS_TERMCAP_so="$(tput setaf 0; tput setab 3)"
export LESS_TERMCAP_us="$(tput bold; tput setaf 2)"

# End blink, bold, reverse ('me' ends all 3), standout, underline
export LESS_TERMCAP_me="$(tput sgr0)"
export LESS_TERMCAP_se="$(tput sgr0)"
export LESS_TERMCAP_ue="$(tput sgr0)"

# Use vim as the default editor
export EDITOR="nvim"
alias vim="nvim"

# Default fzf options
export FZF_DEFAULT_OPTS="--no-256"

# Key bindings for fzf
[[ -r ~/.fzf.bash ]] && source ~/.fzf.bash

# Alias tac if coreutils not installed
if ! type tac &>/dev/null; then
  alias tac="tail -r"
fi

# Generate and export LS_COLORS
[[ -r ~/.dircolors ]] && eval "$(dircolors ~/.dircolors)"

# Color ls output
if ls --color=auto &>/dev/null; then
  alias ls="ls -bp --color=auto"
elif ls -G &>/dev/null; then
  alias ls="ls -bGp"
else
  alias ls="ls -bp"
fi

# Aliases for viewing directory contents
alias ll="ls -hl"
alias la="ll -A"
alias lt="tree -CF"
alias lta="lt -a"
alias ltg="lta -I .git"

# Aliases for git
alias gs="git status"
alias gc="git commit"
alias ga="git add"
alias gap="git add --patch"
alias gd="git diff"
alias gp="git push"
alias gl="git log --graph --decorate"
alias glo="git log --graph --decorate --oneline"
alias gaa="git add --all"
alias gau="git add --update"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcm="git commit --message"
alias gca="git commit --amend"
alias gpf="git push --force"

# Color grep output
alias grep="grep"

# Include parent directory in PS1
export PROMPT_DIRTRIM=2

# Construct and export PS1
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}


# this is somewhat replicated than parse_git_branch but the former returns
# <space>(<branch name>)<space> that's appropriate for PS1 but not usable 
# for using in git refs
current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}
alias ggpull='git pull origin $(current_branch)'
alias ggpush='git push origin $(current_branch)'
alias ggpnp='git pull origin $(current_branch) && git push origin $(current_branch)'

get_change_statuses() {
  local s='';

  # Check if the current directory is in a Git repository.
  if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then

    # check if the current directory is in .git before running git checks
    if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

      # Ensure the index is up to date.
      git update-index --really-refresh -q &>/dev/null;

      # Check for uncommitted changes in the index.
      if ! $(git diff --quiet --ignore-submodules --cached); then
        s+='+';
      fi;

      # Check for unstaged changes.
      if ! $(git diff-files --quiet --ignore-submodules --); then
        s+='!';
      fi;

      # Check for untracked files.
      if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        s+='?';
      fi;

      # Check for stashed files.
      if $(git rev-parse --verify refs/stash &>/dev/null); then
        s+='$';
      fi;

      # If there are no flags don't print anything
      if [ -n "$s" ]; then
        echo -e " (${s})";
      fi;
    fi;
  else
    return;
  fi;
 }

make_ps1() {
  local reset red green yellow blue white user host dir status

  # Color escape sequences
  reset="$(tput sgr0)"
  red="$(tput setaf 1)"
  green="$(tput setaf 2)"
  yellow="$(tput setaf 3)"
  blue="$(tput setaf 4)"
  white="$(tput setaf 7)"
  orange="$(tput setaf 166)";

  # Red user if root, green otherwise
  [[ $UID -eq 0 ]] && user="\[$red\]" || user="\[$green\]"

  # Blue host
  host="\[$blue\]"

  # Yellow working directory
  dir="\[$yellow\]"

  # White git branch
  git_branch="\[$white\]"

  # Orange statuses for file changes
  # +: has uncommited changes
  # !: has unstaged changes
  # ?: has untracked files
  # $: has stashed changes
  git_file_change_statuses="\[$orange\]"

  # Red $ or # if non-zero exit status, normal otherwise
  status='$((( $? )) && printf "%b" "'"$red"'" || printf "%b" "'"$reset"'")'

  # user@host pwd $
  export PS1="\[$reset\]$user\u$host@$C9_HOSTNAME $dir\w$git_branch\$(parse_git_branch)$git_file_change_statuses\$(get_change_statuses) \[$status\]$(printf "\xe2\x9a\x93") \[$reset\]"
}

make_ps1
unset -f make_ps1

# Source bash completion, functions, and local settings
[[ -r /usr/local/etc/bash_completion ]] && source /usr/local/etc/bash_completion
[[ -r ~/.bash_completion ]] && source ~/.bash_completion
[[ -r ~/.bash_functions ]] && source ~/.bash_functions
[[ -r ~/.bash_local ]] && source ~/.bash_local
[[ -r /opt/google-cloud-sdk/completion.bash.inc ]] && source /opt/google-cloud-sdk/completion.bash.inc
[[ -r /opt/google-cloud-sdk/path.bash.inc ]] && source /opt/google-cloud-sdk/path.bash.inc

if $( env | grep "termux" >/dev/null ) ; then
  if ! pgrep -f "proot" >/dev/null ; then echo "[Starting chroot...]" && termux-chroot; else echo "[chroot is running]"; fi

  if ! pgrep "sshd" >/dev/null ; then echo "[Starting sshd...]" && sshd && echo "[OK]"; else echo "[ssh is running]"; fi
fi;

if [[ -d /data/data/com.termux ]]; then
  # dep's locking mechanism doesn't work in termux. See some relevant discussion in https://github.com/golang/dep/issues/947
  export DEPNOLOCK=1
fi

# Load NVM to manage node versions
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

kubecfg () {
  gcloud container clusters get-credentials $2-cluster --region us-west1 --project $(./scripts/env-project-id.sh $1)
}

# Runs the gcloud authentication to make sure docker pull and rest of things work
function fix_gcloud_auth(){
  gcloud auth application-default login
  gcloud auth login
  gcloud auth configure-docker
}

function extract () {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
  }

export DOCKER_CLI_EXPERIMENTAL=enabled

export GOROOT="$HOME/.go"

# Go paths and for python/ipython paths
export PATH="$PATH:$HOME/.go/bin:$HOME/go/bin:$HOME/.local/bin"

# Base16 Shell
BASE16_SHELL="$HOME/dotfiles/configs/base16-shell/"
[ -n "$PS1" ] && \
  [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
    eval "$("$BASE16_SHELL/profile_helper.sh")"

# ignoreboth ignores duplicates and lines starting with a space
export HISTCONTROL=ignoreboth:erasedups

# increase the history size from the default 500
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE

# append to history file instead of overwriting
shopt -s histappend

# setup direnv
eval "$(direnv hook bash)"

# Allow user-specific configuration
[[ -r ~/.config/dotfiles/.bash_profile ]] && source ~/.config/dotfiles/.bash_profile
# Don't make edits below this line
# -------------------------------------------
