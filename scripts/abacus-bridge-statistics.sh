#!/bin/bash
set -e

if [ -z "$SYSTEM_CLIENT_ID" ] || [ -z "$SYSTEM_CLIENT_SECRET" ]; then
  echo "Missing SYSTEM_CLIENT_ID or SYSTEM_CLIENT_SECRET !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $SYSTEM_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user $SYSTEM_CLIENT_ID:$SYSTEM_CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "No token found ! Are your credentials correct (SYSTEM_CLIENT_ID and SYSTEM_CLIENT_SECRET)?"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Getting abacus-cf-bridge URL ..."
URL=$(cf app ${ABACUS_PREFIX}abacus-cf-bridge | awk '{if (NR == 7) {print $2}}')

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
