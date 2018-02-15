#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-hao] <page number>

Shows service usage events
  -h    display this help and exit
  -o    filter organization
  -a    show all events
EOF
}

if [ -z "$ABACUS_CC_CLIENT_ID" ] || [ -z "$ABACUS_CC_CLIENT_SECRET" ]; then
  echo "Missing ABACUS_CC_CLIENT_ID or ABACUS_CC_CLIENT_SECRET !"
  exit 1
fi

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
show_all=0
filter_org=0
page=$1

while getopts "hao:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      a)
        show_all=1
        ;;
      o)
        filter_org=1
        ORG_GUID=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "Arguments: show_all='$show_all', org='$ORG_GUID', page='$page', Leftovers: $@"
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

echo "Service usage events metadata:"
EVENTS=$(curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/service_usage_events?results-per-page=1" | jq '.total_results')
PAGES=$((EVENTS / 100 + 1))
echo "   events: $EVENTS"
echo "   pages : $PAGES"
echo ""

if [ $show_all = 1 ]; then
  FILTER=".resources[].entity"

  if [ $filter_org = 1 ]; then
    if [ -z $ORG_GUID ]; then
      ORG=$(cf target | awk '{if (NR == 4) {print $2}}')
      echo "Get organization $ORG guid ..."
      set +e
      ORG_GUID=$(cf org $ORG --guid)
      if [ $? != 0 ]; then
        echo "Organization $ORG not found !"
        exit 1
      fi
      set -e
      echo "Done."
      echo ""
    else
      echo "Using organization guid $ORG_GUID"
      echo ""
    fi

    FILTER=".resources[].entity | select(.org_guid == \"$ORG_GUID\")"
  fi

  for ((i=1;i<=PAGES;i++)); do
    echo "Listing events on page: $i ..."
    curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/service_usage_events?results-per-page=100&page=$i" | jq "$FILTER"
  done
else
  if [ -z $page ]; then
    echo "No page specified !"
    exit 1
  fi

  echo "Get service usage event #$page..."
  curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/service_usage_events?results-per-page=100&page=$page"
fi
