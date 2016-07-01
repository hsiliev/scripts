#!/bin/bash

echo Setting proxy...

PROXY_HOST=proxy.wdf.sap.corp
PROXY_PORT=8080

# Proxy Settings
export http_proxy=http://$PROXY_HOST:$PROXY_PORT
export HTTP_PROXY=$http_proxy
export https_proxy=$http_proxy
export HTTPS_PROXY=$http_proxy
export no_proxy=localhost,127.0.0.1,192.168.50.4,192.168.99.100,xip.io,.wdf.sap.corp
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

# maven proxy
if [ -e $HOME/.m2/inactive-settings.xml ]; then
  mv $HOME/.m2/inactive-settings.xml $HOME/.m2/settings.xml
else
  cat << EOF > $HOME/.m2/settings.xml
  <settings xmlns="http://maven.apache.org/SETTINGS/1.1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd">
    <proxies>
     <proxy>
        <id>sap-proxy</id>
        <active>true</active>
        <protocol>http</protocol>
        <host>proxy.wdf.sap.corp</host>
        <port>8080</port>
        <nonProxyHosts>*.wdf.sap.corp</nonProxyHosts>
      </proxy>
    </proxies>
  </settings>
EOF
fi

# Reset DNS cache
$HOME/scripts/dnsflush.sh
