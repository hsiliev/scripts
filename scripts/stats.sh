#!/bin/bash
set -x -e

cf curl /v2/apps/$1?async=true -X PUT -d '{"state":"STARTED"}'

while true
do
  OUTPUT=`cf curl /v2/apps/$1`
  if ! [[ $OUTPUT =~ "staging_failed_reason\": null" ]]
  then
    echo "Start FAILED"
    exit
  fi
  sleep 0.3
done
