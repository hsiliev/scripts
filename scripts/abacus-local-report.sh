#!/bin/bash

ORG_GUID=$1
if [[ -z "$ORG_GUID" ]]; then
  ORG_GUID=34db180b-dc68-4305-bd95-a9af80ba7c4c
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

url="http://localhost:9088/v1/metering/organizations/$ORG_GUID/aggregated/usage"
echo "Getting usage from $url ..."
if [ -n "$SECURED" ]; then
  echo "curl -k -H 'Content-Type: application/json' -H 'Authorization: bearer $token' $url"
  OUTPUT=$(curl -k -H "Content-Type: application/json" -H "Authorization: bearer $token" $url)
else
  echo "curl -H 'Content-Type: application/json' $url"
  OUTPUT=$(curl -H "Content-Type: application/json" $url)
fi

if [[ $OUTPUT = "{}" ]]; then
  echo ""
  echo "Report is empty: $OUTPUT"
  exit 0
fi

if [[ ! $OUTPUT =~ \{.*\} ]]; then
  echo ""
  echo "No report data! Original response: $OUTPUT"
  echo ""
  echo "Running diagnostics request ..."
  if [ -n "$SECURED" ]; then
    curl -k -i -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL
  else
    curl -H "Content-Type: application/json" $url
  fi
else
  echo $OUTPUT | jq .
fi
