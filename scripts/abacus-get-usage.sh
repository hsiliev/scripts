#!/bin/bash

set -e

SCOPE="abacus.usage.read"
if [ -n "$RESOURCE_ID" ]; then
  SCOPE="abacus.usage.$RESOURCE_ID.read"
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Reading user id and secret from app bridge..."
  CLIENT_ID=$(cf env ${ABACUS_PREFIX}abacus-applications-bridge | grep -w CLIENT_ID | awk '{ print $2 }')
  CLIENT_SECRET=$(cf env ${ABACUS_PREFIX}abacus-applications-bridge | grep -w CLIENT_SECRET | awk '{ print $2 }')
  echo ""
fi

echo "Getting token for $CLIENT_ID with scope $SCOPE from $AUTH_SERVER ..."
echo ">>> curl -i --user $CLIENT_ID:$CLIENT_SECRET -k -s '$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE'"
TOKEN=$(curl --user $CLIENT_ID:$CLIENT_SECRET -k -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "No token found ! Are your credentials correct (CLIENT_ID and CLIENT_SECRET)?"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Getting first CF domain ..."
DOMAIN=$(cf domains | awk '{if (NR == 3) {print $1}}')
DOMAIN=${DOMAIN/cfapps/cf}
echo "Using domain $DOMAIN"
echo ""
if [ -z "$DOMAIN" ]; then
  echo "No domain found ! Are your logged in CF?"
  exit 1
fi

echo ">>> curl -ik -H 'Authorization: bearer $TOKEN' -H 'Content-Type: application/json' $1"
curl -ik -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $1
