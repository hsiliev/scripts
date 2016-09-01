#!/bin/bash
set -e

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Missing ABACUS_CLIENT_ID or ABACUS_CLIENT_SECRET !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{print $3}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $ABACUS_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user $ABACUS_CLIENT_ID:$ABACUS_CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ "$TOKEN" == "null" ]; then
  echo "No token found !"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Getting abacus-cf-bridge URL ..."
URL=$(cf app abacus-cf-bridge | awk '{if (NR == 7) {print $2}}')
if [ -z "$URL" ]; then
  echo "Cannot find URL! Have you targeted abacus org/space?"
  exit 1
fi
URL="https://$URL/v1/cf/bridge"
echo "Using $URL"
echo ""

echo "Getting statistics ..."
set +e
OUTPUT=$(curl -sH "Authorization: bearer $TOKEN" $URL | jq 'del(.bridge.performance)')
set -e
if [ "$OUTPUT" == *"parse error"* ] || [ "$OUTPUT" == *"jq: error"* ] || [ -z "$OUTPUT" ]; then
  echo ""
  echo "Dumping raw response ..."
  curl -i -H "Authorization: bearer $TOKEN" $URL
else
  echo $OUTPUT | jq .
fi
