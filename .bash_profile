#!/usr/bin/env bash

# Go Settings
export GOPATH=~/workspace/Go
launchctl setenv GOPATH $GOPATH
GOVERSION=$(brew list go | head -n 1 | cut -d '/' -f 6)
export GOROOT=$(brew --prefix)/Cellar/go/$GOVERSION/libexec
#export GOROOT=/usr/local/go
launchctl setenv GOROOT $GOROOT
export GOOS=darwin
launchctl setenv GOOS $GOOS
export GOARCH=amd64
launchctl setenv GOARCH $GOARCH
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
export JAVA_HOME=`/usr/libexec/java_home -v 11`
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
ulimit -u 2048

# fix for MacVIM, Python, YCM & vim incompatibility
export DYLD_FORCE_FLAT_NAMESPACE=1

# go to workspace
cd $HOME/workspace

# abacus dev
export ABACUS_HOME=/Users/development/workspace/cf-abacus
export NO_ISTANBUL=true

# iTerm shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# BASH completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
. $(brew --prefix)/etc/bash_completion
fi
