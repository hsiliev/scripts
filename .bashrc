#!/usr/bin/env bash

function goto {
  local p
  local f
 
  for p in `echo $GOPATH | tr ':' '\n'`; do
    f=`find ${p}/src -type d -not -path '*/.*' | grep "${1}" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | head -n 1`
    if [ -n "$f" ]; then
      cd $f
      return
    fi
  done
 
  workto "$@"
}
 
function workto {
  local p
  local f
 
  f=`find ~/workspace -type d -not -path '*/.*' | grep "${1}" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | head -n 1`
  if [ -n "$f" ]; then
    cd $f
    return
  fi
}

# aliases
alias ll="ls -la"
alias set-proxy="source $HOME/scripts/set-proxy.sh"
alias unset-proxy="source $HOME/scripts/unset-proxy.sh"
alias goddamit="$HOME/scripts/deploy.sh"

# scripts
export PATH="$HOME/scripts:$PATH"

# AWS
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Path to the bash it configuration
export BASH_IT=$HOME/.bash_it

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_IT_THEME='bobby'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

#
# cloud_controller_ng
#
export DB_CONNECTION_STRING="mysql2://root:password@localhost:3306/cc_test"
export DB="mysql"

#
# rbenv
#
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
eval "$(rbenv init -)"

# Load Bash It
source $BASH_IT/bash_it.sh

# direnv
eval "$(direnv hook bash)"

# go to workspace
cd workspace

