#!/bin/bash
set -e

if [ -z "$DEBUG_CLIENT_ID" ] || [ -z "$DEBUG_CLIENT_SECRET" ]; then
  echo "Missing DEBUG_CLIENT_ID or DEBUG_CLIENT_SECRET !"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Missing application name"
  echo ""
  echo "Usage: abacus-debug <app name> <filter>"
  exit 1
fi

if [ -z "$2" ]; then
  echo "Missing DEBUG filter"
  echo ""
  echo "Usage: abacus-debug <app name> <filter>"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $DEBUG_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user $DEBUG_CLIENT_ID:$DEBUG_CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=abacus.debug.write%20abacus.debug.read" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "No token found ! Are your credentials correct (DEBUG_CLIENT_ID and DEBUG_CLIENT_SECRET)?"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Getting $1 URL ..."
URL=$(cf app ${ABACUS_PREFIX}${1} | awk '{if (NR == 7) {print $2}}')

if [ -z "$URL" ]; then
  echo "Cannot find URL! Have you targeted abacus org/space?"
  exit 1
fi
URL="https://$URL/debug?config=$2"
echo "Using $URL"
echo ""

echo "Setting DEBUG to $2 ..."
curl -isH "Authorization: bearer $TOKEN" "$URL"
