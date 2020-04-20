#!/bin/bash

org_guid=$1
if [[ -z "$org_guid" ]]; then
  org_guid=34db180b-dc68-4405-bd95-a9af80ba7c4c
fi
echo "Using org $org_guid"

if [ -n "$SECURED" ]; then
  scope="abacus.usage.read"
  if [ ! -z "$RESOURCE_ID" ]; then
    scope="abacus.usage.$RESOURCE_ID.read"
  fi

  echo "Getting token for scope $scope from local auth server ..."
  token=$(curl -k -X POST -s "http://localhost:9882/oauth/token?grant_type=client_credentials&scope=$scope" | jq -r .access_token)
  if [ "$token" == "null" ] || [ -z "$token" ]; then
    echo ""
    echo "No token found ! Running diagnostics ..."
    exit 1
  fi
  echo "Obtained token $token"
  echo ""
fi

url="http://localhost:9088/v1/metering/organizations/$org_guid/aggregated/usage/$DATE_IN_MS"
echo "Getting usage from $url ..."
if [ -n "$SECURED" ]; then
  echo "curl -k -H 'Content-Type: application/json' -H 'Authorization: bearer $token' $url"
  curl -k -H "Content-Type: application/json" -H "Authorization: bearer $token" $url | jq .
else
  echo "curl -H 'Content-Type: application/json' $url"
  curl -H "Content-Type: application/json" $url | jq .
fi
