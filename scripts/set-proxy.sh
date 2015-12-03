#!/bin/bash

echo Setting proxy... 

# Proxy Settings
export http_proxy=http://proxy.wdf.sap.corp:8080
export https_proxy=$http_proxy
export no_proxy=localhost,127.0.0.1,192.168.50.4,xip.io,.wdf.sap.corp
launchctl setenv http_proxy $http_proxy
launchctl setenv https_proxy $https_proxy
launchctl setenv no_proxy $no_proxy

# npm proxy
npm config set proxy http://proxy.wdf.sap.corp:8080
npm config set https-proxy http://proxy.wdf.sap.corp:8080

# Reset DNS cache
$HOME/scripts/dnsflush.sh
