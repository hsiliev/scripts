#!/bin/bash

echo Setting proxy...

PROXY_HOST=proxy.wdf.sap.corp
PROXY_PORT=8080

# Proxy Settings
export http_proxy=http://$PROXY_HOST:$PROXY_PORT
export https_proxy=$http_proxy
export no_proxy=localhost,127.0.0.1,192.168.50.4,xip.io,.wdf.sap.corp
launchctl setenv http_proxy $http_proxy
launchctl setenv https_proxy $https_proxy
launchctl setenv no_proxy $no_proxy

# npm proxy
npm config set proxy http://proxy.wdf.sap.corp:8080
npm config set https-proxy http://proxy.wdf.sap.corp:8080

# java proxy
if [[ $JAVA_OPTS != *"proxyHost"* ]]; then
  export ORIGINAL_JAVA_OPTS=$JAVA_OPTS
  export JAVA_OPTS="$JAVA_OPTS -Dhttp.proxyHost=$PROXY_HOST -Dhttp.proxyPort=$PROXY_PORT -Dhttps.proxyHost=$PROXY_HOST -Dhttps.proxyPort=$PROXY_PORT"
else
  echo "Java proxy already set"
fi

# Reset DNS cache
$HOME/scripts/dnsflush.sh
