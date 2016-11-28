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

# Path
export PATH=$PATH:$GOPATH/bin:$HOME/scripts:$HOME/bin

# rbenv
eval "$(rbenv init -)"

export NVM_DIR=~/.nvm
. $(brew --prefix nvm)/nvm.sh

# aliases
alias ll="ls -la"
alias set-proxy="source $HOME/scripts/set-proxy.sh"
alias unset-proxy="source $HOME/scripts/unset-proxy.sh"
alias goddamit="$HOME/scripts/deploy.sh"

# Java
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
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
# dockermachine
#
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/development/.docker/machine/machines/dev"
export DOCKER_MACHINE_NAME="dev"

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

# abacus ops
export ABACUS_CF_BRIDGE_CLIENT_ID=abacus-cf-bridge
export ABACUS_CF_BRIDGE_CLIENT_SECRET=secret
export SYSTEM_CLIENT_ID=abacus
export SYSTEM_CLIENT_SECRET=secret
export CLIENT_ID=abacus-linux-container
export CLIENT_SECRET=secret

function abacus-module {
  local p
  local f

   
  for p in `echo $ABACUS_HOME | tr ':' '\n'`; do
    f=`find ${p}/lib -type d -not -path '*/.*' | grep "${1}" | awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | head -n 1`
    if [ -n "$f" ]; then
      cd $f
      return
    fi
  done
}

# concourse jumpbox
export concourse_ip=127.0.0.1
export concourse_port=8888
export concourse_platform=${OSTYPE//[0-9.]/}

# iTerm shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
