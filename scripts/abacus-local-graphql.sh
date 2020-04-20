#!/bin/bash
set -e

DATE_IN_MS="$(date +%s000)"
URL="http://localhost:9088/v1/metering/aggregated/usage/graph/"
QUERY=$(node -p "encodeURIComponent('$1')")

echo $QUERY

echo "Using $URL"
echo ""

echo "Getting report with query $1 from $URL ..."
echo ">>> curl -ksG -H 'Content-Type: application/json' $URL$QUERY | jq ."
curl -ksG -H "Content-Type: application/json" -H "Authorization: bearer $TOKEN" $URL$QUERY | jq .
