#
# Teh H4xx
#

# if [ "$(uname)" = "Darwin" ]; then
#   # Suppress unwanted Homebrew-installed stuff.
#   if [ -e /usr/local/share/zsh/site-functions/_git ]; then
#     mv -f /usr/local/share/zsh/site-functions/{,disabled.}_git
#   fi
# fi

# #
# # Completion
# #

fpath=($HOME/.zsh/completions $fpath)

autoload -U compinit
compinit -u

# Make completion:
# - Case-insensitive.
# - Accept abbreviations after . or _ or - (ie. f.b -> foo.bar).
# - Substring complete (ie. bar -> foobar).
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors ''

#
# Correction
#

# # exceptions to auto-correction
# alias bundle='nocorrect bundle'
# alias cabal='nocorrect cabal'
# alias man='nocorrect man'
# alias mkdir='nocorrect mkdir'
# alias mv='nocorrect mv'
# alias stack='nocorrect stack'
# alias sudo='nocorrect sudo'

#
# Prompt
#

autoload -U colors
colors

# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%F{green}●%f" # default 'S'
zstyle ':vcs_info:*' unstagedstr "%F{red}●%f" # default 'U'
zstyle ':vcs_info:*' use-simple true
zstyle ':vcs_info:git+set-message:*' hooks git-untracked
zstyle ':vcs_info:git*:*' formats '[%b%m%c%u] ' # default ' (%s)-[%b]%c%u-'
zstyle ':vcs_info:git*:*' actionformats '[%b|%a%m%c%u] ' # default ' (%s)-[%b|%a]%c%u-'
zstyle ':vcs_info:hg*:*' formats '[%m%b] '
zstyle ':vcs_info:hg*:*' actionformats '[%b|%a%m] '
zstyle ':vcs_info:hg*:*' branchformat '%b'
zstyle ':vcs_info:hg*:*' get-bookmarks true
zstyle ':vcs_info:hg*:*' get-revision true
zstyle ':vcs_info:hg*:*' get-mq false
zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks
zstyle ':vcs_info:hg*+set-message:*' hooks hg-message

# function +vi-hg-bookmarks() {
#   emulate -L zsh
#   if [[ -n "${hook_com[hg-active-bookmark]}" ]]; then
#     hook_com[hg-bookmark-string]="${(Mj:,:)@}"
#     ret=1
#   fi
# }

# function +vi-hg-message() {
#   emulate -L zsh

#   # Suppress hg branch display if we can display a bookmark instead.
#   if [[ -n "${hook_com[misc]}" ]]; then
#     hook_com[branch]=''
#   fi
#   return 0
# }

function +vi-git-untracked() {
  emulate -L zsh
  if [[ -n $(git ls-files --exclude-standard --others 2> /dev/null) ]]; then
    hook_com[unstaged]+="%F{blue}●%f"
  fi
}

RPROMPT_BASE="\${vcs_info_msg_0_}%F{blue}%~%f"
setopt PROMPT_SUBST

# Anonymous function to avoid leaking NBSP variable.
function () {
  if [[ -n "$TMUX" ]]; then
    local LVL=$(($SHLVL - 1))
  else
    local LVL=$SHLVL
  fi
  if [[ $EUID -eq 0 ]]; then
    local SUFFIX=$(printf '#%.0s' {1..$LVL})
  else
    local SUFFIX=$(printf '\$%.0s' {1..$LVL})
  fi
  if [[ -n "$TMUX" ]]; then
    # Note use a non-breaking space at the end of the prompt because we can use it as
    # a find pattern to jump back in tmux.
    local NBSP=' '
    export PS1="%F{green}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b%F{blue}%1~%F{yellow}%B%(1j.*.)%(?..!)%b%f%F{red}%B${SUFFIX}%b%f${NBSP}"
    export ZLE_RPROMPT_INDENT=0
  else
    # Don't bother with ZLE_RPROMPT_INDENT here, because it ends up eating the
    # space after PS1.
    export PS1="%F{green}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b%F{blue}%1~%F{yellow}%B%(1j.*.)%(?..!)%b%f%F{red}%B${SUFFIX}%b%f "
  fi
}

export RPROMPT=$RPROMPT_BASE
export SPROMPT="zsh: correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "

#
# History
#

export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

#
# Options
#

# .. is shortcut for cd .. (etc)
setopt autocd
# tab completing directory appends a slash
setopt autoparamslash
# cd automatically pushes old dir onto dir stack
setopt autopushd
# allow clobbering with >, no need to use >!
setopt clobber
# command auto-correction
setopt correct
# argument auto-correction
setopt correctall
# disable start (C-s) and stop (C-q) characters
setopt noflowcontrol
# unmatched patterns are left unchanged
setopt nonomatch
# filter duplicates from history
setopt histignorealldups
# don't record commands starting with a space
setopt histignorespace
# confirm history expansion (!$, !!, !foo)
setopt histverify
# prevent accidental C-d from exiting shell
setopt ignoreeof
# allow comments, even in interactive shells
setopt interactivecomments
# for non-zero exit status
setopt printexitvalue
# don't push multiple copies of same dir onto stack
setopt pushdignoredups
# don't print dir stack after pushing/popping
setopt pushdsilent
# share history across shells
setopt sharehistory

#
# Bindings
#

bindkey -e # emacs bindings, set to -v for vi bindings

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "\e[A" history-beginning-search-backward-end  # cursor up
bindkey "\e[B" history-beginning-search-forward-end   # cursor down

autoload -U select-word-style
select-word-style bash # only alphanumeric chars are considered WORDCHARS

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^x' edit-command-line

bindkey ' ' magic-space # do history expansion on space

# Replace standard history-incremental-search-{backward,forward} bindings.
# These are the same but permit patterns (eg. a*b) to be used.
bindkey "^r" history-incremental-pattern-search-backward
bindkey "^s" history-incremental-pattern-search-forward

# Make CTRL-Z background things and unbackground them.
function fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
  else
    zle push-input
  fi
}
zle -N fg-bg
bindkey '^Z' fg-bg

#
# Other
#

source $HOME/.zsh/aliases
# source $HOME/.zsh/common
source $HOME/.zsh/colors
source $HOME/.zsh/exports
# source $HOME/.zsh/functions
# source $HOME/.zsh/hash
# source $HOME/.zsh/path
# source $HOME/.zsh/vars

# test -e $HOME/.zsh/functions.private && source $HOME/.zsh/functions.private

#
# Third-party
#

# CHRUBY=/usr/local/share/chruby
# test -e "$CHRUBY/chruby.sh" && . "$CHRUBY/chruby.sh"
# test -e "$CHRUBY/auto.sh" && . "$CHRUBY/auto.sh"

#
# Hooks
#

autoload -U add-zsh-hook

function set-tab-and-window-title() {
  emulate -L zsh
  local CMD="${1:gs/$/\\$}"
  print -Pn "\e]0;$CMD:q\a"
}

function update-window-title-precmd() {
  emulate -L zsh
  set-tab-and-window-title `history | tail -1 | cut -b8-`
}
add-zsh-hook precmd update-window-title-precmd

function update-window-title-preexec() {
  emulate -L zsh
  setopt extended_glob

  # skip ENV=settings, sudo, ssh; show first distinctive word of command;
  # mostly stolen from:
  #   https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/termsupport.zsh
  set-tab-and-window-title ${2[(wr)^(*=*|mosh|ssh|sudo)]}
}
add-zsh-hook preexec update-window-title-preexec

typeset -F SECONDS
function record-start-time() {
  emulate -L zsh
  ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
}

add-zsh-hook preexec record-start-time

function report-start-time() {
  emulate -L zsh
  if [ $ZSH_START_TIME ]; then
    local DELTA=$(($SECONDS - $ZSH_START_TIME))
    local DAYS=$((~~($DELTA / 86400)))
    local HOURS=$((~~(($DELTA - $DAYS * 86400) / 3600)))
    local MINUTES=$((~~(($DELTA - $DAYS * 86400 - $HOURS * 3600) / 60)))
    local SECS=$(($DELTA - $DAYS * 86400 - $HOURS * 3600 - $MINUTES * 60))
    local ELAPSED=''
    test "$DAYS" != '0' && ELAPSED="${DAYS}d"
    test "$HOURS" != '0' && ELAPSED="${ELAPSED}${HOURS}h"
    test "$MINUTES" != '0' && ELAPSED="${ELAPSED}${MINUTES}m"
    if [ "$ELAPSED" = '' ]; then
      SECS="$(print -f "%.2f" $SECS)s"
    elif [ "$DAYS" != '0' ]; then
      SECS=''
    else
      SECS="$((~~$SECS))s"
    fi
    ELAPSED="${ELAPSED}${SECS}"
    local ITALIC_ON=$'\e[3m'
    local ITALIC_OFF=$'\e[23m'
    export RPROMPT="%F{cyan}%{$ITALIC_ON%}${ELAPSED}%{$ITALIC_OFF%}%f $RPROMPT_BASE"
    unset ZSH_START_TIME
  else
    export RPROMPT="$RPROMPT_BASE"
  fi
}

# add-zsh-hook precmd report-start-time

# TODO
# add-zsh-hook precmd bounce

function auto-ls-after-cd() {
  emulate -L zsh
  # Only in response to a user-initiated `cd`, not indirectly (eg. via another
  # function).
  if [ "$ZSH_EVAL_CONTEXT" = "toplevel:shfunc" ]; then
    ls
  fi
}
# add-zsh-hook chpwd auto-ls-after-cd

# for prompt
add-zsh-hook precmd vcs_info

# adds `cdr` command for navigating to recent directories
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# enable menu-style completion for cdr
zstyle ':completion:*:*:cdr:*:*' menu selection

# fall through to cd if cdr is passed a non-recent dir as an argument
zstyle ':chpwd:*' recent-dirs-default true

# Local and host-specific overrides.

# DEV_RC=$HOME/.zsh/host/dev-star
# if [ $(hostname -s) =~ '^dev(vm)?[[:digit:]]+' ]; then
#   test -f $DEV_RC && source $DEV_RC
# fi

# HOST_RC=$HOME/.zsh/host/$(hostname -s)
# test -f $HOST_RC && source $HOST_RC

# LOCAL_RC=$HOME/.zshrc.local
# test -f $LOCAL_RC && source $LOCAL_RC

#
# Plug-ins
#

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=59'

# Uncomment this to get syntax highlighting:
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#
# /etc/motd
#

# if [ -e /etc/motd ]; then
#   if ! cmp -s $HOME/.hushlogin /etc/motd; then
#     tee $HOME/.hushlogin < /etc/motd
#   fi
# fi
