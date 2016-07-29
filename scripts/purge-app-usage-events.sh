#!/bin/bash
set -e

if [ -z "$ABACUS_CF_BRIDGE_CLIENT_ID" ] || [ -z "$ABACUS_CF_BRIDGE_CLIENT_SECRET" ]; then
  echo "Missing ABACUS_CF_BRIDGE_CLIENT_ID or ABACUS_CF_BRIDGE_CLIENT_SECRET !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{print $3}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $ABACUS_CF_BRIDGE_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user $ABACUS_CF_BRIDGE_CLIENT_ID:$ABACUS_CF_BRIDGE_CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ "$TOKEN" == "null" ]; then
  echo "No token found !"
  exit 1
fi
echo "Token obtained: $TOKEN"
echo ""

curl -X POST -H "Authorization: bearer $TOKEN" -i "$API/v2/app_usage_events/destructively_purge_all_and_reseed_started_apps"
