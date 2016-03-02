#!/bin/bash
set -e

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Missing CLIENT_ID or CLIENT_SECRET !"
  exit 1
fi
if [ -z "$1" ]; then
  echo "No organization specified !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{print $3}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user $CLIENT_ID:$CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=abacus.usage.linux-container.write%20abacus.usage.linux-container.read" | jq -r .access_token)
if [ "$TOKEN" == "null" ]; then
  echo "No token found !"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Get organization $1 guid ..."
ORG_GUID=$(cf org $1 --guid)
echo "Done."
echo ""

echo "Getting abacus-usage-reporting URL ..."
USAGE_REPORTING=$(cf app abacus-usage-reporting | awk '{if (NR == 7) {print $2}}')
echo "Using $USAGE_REPORTING"
echo ""

echo "Getting organization $1 ($ORG_GUID) from $USAGE_REPORTING ..."
curl -sH "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "https://$USAGE_REPORTING/v1/metering/organizations/${ORG_GUID}/aggregated/usage" | jq .spaces[0]
