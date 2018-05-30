#!/usr/bin/env bash

set -e

app=$1
if [ -z "$app" ]; then
  app=abacus-housekeeper
fi
echo "Using application $ABACUS_PREFIX$app"

services=$(cf env "$ABACUS_PREFIX$app" | grep 'uri":' | sed -e 's/.*"uri": "//g' | sed -e 's/",//g')

namesList=$(cf env "$ABACUS_PREFIX$app" | awk "/mongodb:\/\//,/\"name\"/ {print}" | grep '"name":')
namesList=$(echo $namesList | sed 's/\"name\": \"//g')
namesList=$(echo $namesList | sed 's/\",//g')
IFS=' ' read -r -a names <<< "$namesList"

#
# port 27017 is used by local mongo for testing and replication
#
port=27018
i=0

connections=()

for url in $services; do
  mongoInstances=$(echo $url | grep -o "@.*/")
  # remove leading and trailing chars
  mongoInstances=${mongoInstances#@}
  mongoInstances=${mongoInstances%/}

  #
  # disable error checking to workaround connection timeout
  #
  set +e

  IFS=', ' read -r -a mongoIPs <<< "$mongoInstances"
  for ip in "${mongoIPs[@]}"; do
    cf ssh -N -L $port:$ip "$ABACUS_PREFIX$app" &
    sleep 4
    connectionString=${url/$mongoInstances/localhost:$port}
    connectionString=${connectionString%\?*}
    isMaster=$(mongo $connectionString --quiet --eval "d=db.isMaster(); print( d['ismaster'] );")
    if [ "$isMaster" == "true" ]; then
      echo "${names[$i]} URL: $connectionString"
      connections+=($connectionString)
    fi
    port=$((port+1))
  done

  #
  # enable error checking again
  #
  set -e

  i=$((i+1))
done

echo ""
echo "CONNECTIONS=("
printf "\"%s\"\n" "${connections[@]}"
echo ")"
