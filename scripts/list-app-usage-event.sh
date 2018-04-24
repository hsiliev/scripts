#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-hfa] <page number>

Shows app usage events
  -h    display this help and exit
  -f    filter current organization
  -a    show all events
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
show_all=0
filter_org=0
page=$1

while getopts "haf:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      a)
        show_all=1
        unset page
        ;;
      f)
        show_all=1
        unset page
        ORG_GUID=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "Arguments: show_all='$show_all', filter_org='$ORG_GUID', page='$page', Leftovers: $@"
echo ""

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

if [ -z "$ABACUS_CF_BRIDGE_CLIENT_ID" ] || [ -z "$ABACUS_CF_BRIDGE_CLIENT_SECRET" ]; then
  echo "Reading system user id and secret ..."
  cf target -o SAP_abacus -s abacus
  ABACUS_CF_BRIDGE_CLIENT_ID=$(cf env abacus-applications-bridge | grep CF_CLIENT_ID | awk '{ print $2 }')
  ABACUS_CF_BRIDGE_CLIENT_SECRET=$(cf env abacus-applications-bridge  | grep CF_CLIENT_SECRET | awk '{ print $2 }')
  echo ""
fi

echo "Getting token for $ABACUS_CF_BRIDGE_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl -k --user "$ABACUS_CF_BRIDGE_CLIENT_ID:$ABACUS_CF_BRIDGE_CLIENT_SECRET" -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "No token found ! Are your credentials correct (ABACUS_CC_CLIENT_ID and ABACUS_CC_CLIENT_SECRET)?"
  exit 1
fi
echo "Token $TOKEN obtained"
echo ""

echo "Reading events metadata ..."
EVENTS=$(curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000" | jq '.total_results')
PAGES=$((EVENTS / 10000 + 1))
echo "   events: $EVENTS"
echo "   pages : $PAGES"
echo ""

echo "App usage events metadata:"
if [ $show_all = 1 ]; then
  for ((i=1;i<=PAGES;i++)); do
    echo "Listing events on page: $i ..."
    if [[ -z $ORG_GUID ]]; then
      curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000&order-direction=desc&page=$i" | jq .
    else
      curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000&order-direction=desc&page=$i" | jq ".resources[] | select(.entity.org_guid == \"$ORG_GUID\")"
    fi
  done
else
  curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=1" | jq 'del(.resources)'
  if [ -z $page ]; then
    echo "No page specified !"
    exit 1
  fi

  echo "Get app usage event page #$page..."
  curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000&page=$page"
fi
echo ""
