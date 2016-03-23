#!/bin/bash
set -e

if [ -z "$CF_CLIENT_ID" ] || [ -z "$CF_CLIENT_SECRET" ]; then
  echo "Missing CF_CLIENT_ID or CF_CLIENT_SECRET !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{print $3}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $CF_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user "$CF_CLIENT_ID:$CF_CLIENT_SECRET" -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ -z "$TOKEN" ]; then
  echo "No token found !"
  exit 1
fi
echo "Token obtained"
echo ""

if [ -z "$1" ]; then
  echo "Get app usage events metadata ..."
  curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=1" | jq 'del(.resources)'  fi
else
  if [ "$1" == "--all" ]; then
    echo "Listing page $1 usage events ..."
    curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000&page=$2" | jq .
    echo ""
    echo "Total page info:"
    curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000" | jq 'del(.resources)'
  else
    echo "Get app usage events page $1..."
    curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=1&page=$1"
  fi
fi
