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

# aliases
alias ll="ls -la"
alias set-proxy="source $HOME/scripts/set-proxy.sh"
alias unset-proxy="source $HOME/scripts/unset-proxy.sh"
alias goddamit="$HOME/scripts/deploy.sh"

# Java
#export JAVA_HOME=`/usr/libexec/java_home -v 1.6`
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_71.jdk/Contents/Home/

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
# boot2docker
#
export DOCKER_HOST=tcp://192.168.59.103:2376
export DOCKER_CERT_PATH=$HOME/.boot2docker/certs/boot2docker-vm
export DOCKER_TLS_VERIFY=1

#
# cloud_controller_ng
#
export DB_CONNECTION_STRING="mysql2://root:password@localhost:3306/cc_test"
export DB="mysql"

# Load Bash It
source $BASH_IT/bash_it.sh

# direnv
eval "$(direnv hook bash)"

#
# export the path for UI programs such as Checkman
#
launchctl setenv PATH $PATH

#
# increase open file limit
# http://blog.mact.me/2014/10/22/yosemite-upgrade-changes-open-file-limit
#
ulimit -n 65536 65536

# fix for MacVIM, Python, YCM & vim incompatibility
export DYLD_FORCE_FLAT_NAMESPACE=1

# go to workspace
cd $HOME/workspace
