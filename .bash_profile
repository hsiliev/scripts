#!/usr/bin/env bash

# Go Settings
export GOPATH=~/workspace/Go
launchctl setenv GOPATH $GOPATH
export PATH=$PATH:$GOPATH/bin:$HOME/scripts:$HOME/bin;

# Homebrew
export PATH=$PATH:/usr/local/sbin

# rbenv
eval "$(rbenv init -)"

export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"

# aliases
alias ll="ls -laG"
alias env="env | sort"
alias set-proxy="source $HOME/scripts/set-proxy.sh"
alias unset-proxy="source $HOME/scripts/unset-proxy.sh"
alias watch="watch -c"

# Java
export JAVA_HOME=$(/usr/libexec/java_home)
launchctl setenv JAVA_HOME $JAVA_HOME

# Maven
export M2_HOME=$(brew --prefix maven)/libexec
export M2=$M2_HOME/bin
export PATH=$PATH:$M2

# AWS
export LC_ALL=en_US.UTF-8
launchctl setenv LC_ALL $LC_ALL
export LANG=en_US.UTF-8
launchctl setenv LANG $LANG

# Path to the bash it configuration
export BASH_IT=$HOME/.bash_it

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_IT_THEME='bobby'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Set my editor and git editor
#export EDITOR="/usr/bin/mate -w"
#export GIT_EDITOR='/usr/bin/mate -w'

# Set the path nginx
export NGINX_PATH='/opt/nginx'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.

export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/xvzf/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

#
# cloud_controller_ng
#
#export DB_CONNECTION_STRING="mysql2://root:password@localhost:3306/cc_test"
#export DB="mysql"

# Load Bash It
source $BASH_IT/bash_it.sh

# direnv
eval "$(direnv hook bash)"

#
# export the path for UI programs such as Checkman
#
launchctl setenv PATH $PATH

#
# ensure we have increased process open file limit
#
# The real increase happens on system level via
# http://docs.basho.com/riak/latest/ops/tuning/open-files-limit/
#
ulimit -n 65536
ulimit -u 1024

# fix for MacVIM, Python, YCM & vim incompatibility
export DYLD_FORCE_FLAT_NAMESPACE=1

# abacus dev
export ABACUS_HOME=/Users/development/workspace/cf-abacus
export NO_ISTANBUL=true

# iTerm shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# BASH completion
export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# kubectl
source <(kubectl completion bash)

# append history instead of rewriting it
shopt -s histappend
# allow a larger history file
export HISTFILESIZE=1000000
export HISTSIZE=1000000
# ignore duplicates and commands that start with space
export HISTCONTROL=ignoreboth
# ignore these commands
export HISTIGNORE='ls:bg:fg:history'
# record timestamps
export HISTTIMEFORMAT='%F %T '
# use one command per line
shopt -s cmdhist

# go to working directory
cd workspace
