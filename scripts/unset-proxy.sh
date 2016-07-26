#!/bin/bash

echo Removing proxy settings...

unset http_proxy
unset https_proxy
unset no_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
launchctl unsetenv http_proxy
launchctl unsetenv https_proxy
launchctl unsetenv no_proxy

# npm proxy
npm config delete proxy
npm config delete https-proxy

# java proxy
export JAVA_OPTS=$ORIGINAL_JAVA_OPTS

# maven proxy
if [ -e $HOME/.m2/settings.xml ]; then
  mv $HOME/.m2/settings.xml $HOME/.m2/inactive-settings.xml
fi

# Reset DNS cache
$HOME/scripts/dnsflush.sh
