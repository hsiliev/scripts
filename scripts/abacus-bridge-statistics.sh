#!/bin/bash
set -e

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Missing CLIENT_ID or CLIENT_SECRET !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{print $3}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user $CLIENT_ID:$CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ "$TOKEN" == "null" ]; then
  echo "No token found !"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Getting abacus-cf-bridge URL ..."
BRIDGE=$(cf app abacus-cf-bridge | awk '{if (NR == 7) {print $2}}')
if [ -z "$BRIDGE" ]; then
  echo "No bridge deployed !!!"
  exit 1
fi
echo "Using $BRIDGE"
echo ""

echo "Getting statistics ..."
set +e
OUTPUT=$(curl -sH "Authorization: bearer $TOKEN" "https://$BRIDGE/v1/cf/bridge" | jq 'del(.bridge.performance)')
set -e
if [ "$OUTPUT" == *"parse error"* ] || [ "$OUTPUT" == *"jq: error"* ] || [ -z "$OUTPUT" ]; then
  echo ""
  echo "Dumping raw response ..."
  curl -i -H "Authorization: bearer $TOKEN" "https://$BRIDGE/v1/cf/bridge"
else
  echo $OUTPUT | jq .
fi
