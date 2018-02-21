s#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-hao:] organization_id

Shows all apps
  -h    display this help and exit
EOF
}

if [ -z "$ABACUS_CC_CLIENT_ID" ] || [ -z "$ABACUS_CC_CLIENT_SECRET" ]; then
  echo "Missing ABACUS_CC_CLIENT_ID or ABACUS_CC_CLIENT_SECRET !"
  exit 1
fi

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
ORG_GUID=$1

while getopts "hao:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "Arguments: show_all='$show_all', org='$ORG_GUID', Leftovers: $@"
echo ""

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $ABACUS_CC_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl -k --user "$ABACUS_CC_CLIENT_ID:$ABACUS_CC_CLIENT_SECRET" -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "No token found ! Are your credentials correct (ABACUS_CC_CLIENT_ID and ABACUS_CC_CLIENT_SECRET)?"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Events metadata:"
EVENTS=$(curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/apps?results-per-page=1" | jq '.total_results')
PAGES=$((EVENTS / 100 + 1))
echo "   events: $EVENTS"
echo "   pages : $PAGES"
echo ""

if [[ -z $ORG_GUID ]]; then
  for ((i=1;i<=PAGES;i++)); do
    echo "Listing organizations page: $i ..."
    set -x
    curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/organizations?results-per-page=100&page=$i$FILTER" | jq ".resources[].entity"
  done
else
  echo "Get organization $ORG_GUID..."
  curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/organizations/$ORG_GUID" | jq .
fi
