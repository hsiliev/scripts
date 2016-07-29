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
set +e
ORG_GUID=$(cf org $1 --guid)
if [ $? != 0 ]; then
  echo "Organization $1 not found. Assuming this is org GUID ..."
  ORG_GUID=$1
fi
set -e
echo "Done."
echo ""

echo "Getting abacus-cf-bridge domain ..."
APP_URL=$(cf app abacus-cf-bridge | awk '{if (NR == 7) {print $2}}')
if [[ $APP_URL == *"abacus-cf-bridge"* ]]; then
  DOMAIN=${APP_URL/abacus-cf-bridge./}
else
  DOMAIN=${APP_URL/abacus-cf-bridge./}
fi
echo "Using domain $DOMAIN"
echo ""

echo "Getting organization $1 ($ORG_GUID) from $DOMAIN ..."
set +e
OUTPUT=$(curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "https://abacus-usage-reporting.$DOMAIN/v1/metering/organizations/${ORG_GUID}/aggregated/usage" | jq .resources[0].plans[0].aggregated_usage[0])
if [ "$OUTPUT" == "null" ]; then
  echo ""
  echo "No report data! Getting original response:"
  curl -i -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "https://abacus-usage-reporting.$DOMAIN/v1/metering/organizations/${ORG_GUID}/aggregated/usage"
else
  echo $OUTPUT | jq .
fi
