#!/bin/sh
set -e

APP_GUID=`cf app app --guid`
cf curl /v2/apps/${APP_GUID}?async=true -X PUT -d '{"state":"STARTED"}'

AUTH_TOKEN=`cat ~/.cf/config.json | jq -r .AccessToken`

while true
do
  APP_GUID=`cf app app --guid`
  APP_VERSION=`cf curl /v2/apps/${APP_GUID} | jq -r .entity.version`
  PROCESS_GUID="${APP_GUID}-${APP_VERSION}"

  set -x
  OUTPUT=`curl -m 10 -w "respcode: %{http_code}" --header "Authorization: ${AUTH_TOKEN}" http://10.244.16.142:1518/v1/actual_lrps/${PROCESS_GUID}/stats?:guid=${PROCESS_GUID} 2>&1`
  set +x
  if [[ $OUTPUT =~ "respcode: 200" ]]
  then
    echo "FOUND !!!!!!!!!!!!"
    FOUND=true
  fi
  if [[ $OUTPUT =~ "respcode: 404" ]]
  then
    echo ""
    echo ""
    echo "NOT FOUND !!!!!!!!!!!!"
    echo ""
    echo ""
    if [[ $ERROR =~ "true" ]]
    then
      echo ""
      echo "############ ERROR"
      echo ""
      exit
    fi
    if [[ $FOUND =~ "true" ]]
    then
      echo ""
      echo ""
      echo ">>>>>>>>>>>>>>>>>>>>>> TEMPO !! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
      echo ""
      echo ""
      ERROR=true
      continue
    fi 
  fi
done
