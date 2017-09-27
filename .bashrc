# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Bash history and completion
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
complete -cf sudo

# Aliases
alias ls='ls --color'
alias ll='ls -hlk --group-directories-first'
alias cbranch="git rev-parse --abbrev-ref @"
alias cmatlab='matlab -r "cd $PWD"'
alias smatlab='LD_PRELOAD=/usr/lib64/gcc/x86_64-pc-linux-gnu/5.4.0/libubsan.so cmatlab'
alias o='octave --no-gui --silent'

# Environmental variables.
export EDITOR="vim"
export LANG="en_US.utf8"
export MATLABPATH="${HOME}/Documents/MATLAB"
export PATH="${PATH}:${HOME}/bin"

# NIRA Dynamics
if [[ -f ~/.nirarc ]] ; then
    . ~/.nirarc
fi
