#!/bin/bash

echo Removing proxy settings...

unset http_proxy
unset https_proxy
unset no_proxy
launchctl unsetenv http_proxy
launchctl unsetenv https_proxy
launchctl unsetenv no_proxy

# npm proxy
npm config delete proxy
npm config delete https-proxy

# Reset DNS cache
$HOME/scripts/dnsflush.sh

