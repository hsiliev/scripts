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
  echo "No token found ! Are your credentials correct (ABACUS_CLIENT_ID and ABACUS_CLIENT_SECRET)?"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Getting abacus-cf-renewer URL ..."
URL=$(cf app abacus-cf-renewer | awk '{if (NR == 7) {print $2}}')
if [ -z "$URL" ]; then
  echo "Cannot find URL! Have you targeted abacus org/space?"
  exit 1
fi
URL="https://$URL/v1/cf/renewer"
echo "Using $URL"
echo ""

echo "Getting statistics ..."
set +e
OUTPUT=$(curl -sH "Authorization: bearer $TOKEN" $URL | jq 'del(.renewer.performance)')
set -e
if [ "$OUTPUT" == *"parse error"* ] || [ "$OUTPUT" == *"jq: error"* ] || [ -z "$OUTPUT" ]; then
  echo ""
  echo "Dumping raw response ..."
  curl -i -H "Authorization: bearer $TOKEN" $URL
else
  echo $OUTPUT | jq .
fi
