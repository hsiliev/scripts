#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-hf:a] <page number>

Shows service usage events
  -h    display this help and exit
  -f    filter organization guid
  -a    show all events
EOF
}

function echoerr {
  echo "$@" >&2;
}

if [ -z "$ABACUS_CF_BRIDGE_CLIENT_ID" ] || [ -z "$ABACUS_CF_BRIDGE_CLIENT_SECRET" ]; then
  echoerr "Reading user id and secret from services bridge env..."
  ABACUS_CF_BRIDGE_CLIENT_ID=$(cf env ${ABACUS_PREFIX}abacus-services-bridge | grep -w CF_CLIENT_ID | awk '{ print $2 }')
  ABACUS_CF_BRIDGE_CLIENT_SECRET=$(cf env ${ABACUS_PREFIX}abacus-services-bridge | grep -w CF_CLIENT_SECRET | awk '{ print $2 }')
  echoerr ""
fi

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
show_all=0
filter_org=0

while getopts "haf:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      a)
        show_all=1
        ;;
      f)
        filter_org=1
        ORG_GUID=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echoerr "Arguments: show_all='$show_all', filter_org='$filter_org', page='$page', Leftovers: $@"
echoerr ""

echoerr "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echoerr "Using API URL $API"
echoerr ""

echoerr "Getting token for $ABACUS_CF_BRIDGE_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl -k --user "$ABACUS_CF_BRIDGE_CLIENT_ID:$ABACUS_CF_BRIDGE_CLIENT_SECRET" -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echoerr "No token found !"
  exit 1
fi
echoerr "Token obtained"
echoerr ""

echoerr "Service usage events metadata:"
EVENTS=$(curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/service_usage_events?results-per-page=1" | jq '.total_results')
PAGES=$(curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/service_usage_events?results-per-page=100" | jq '.total_pages')
echoerr "   events: $EVENTS"
echoerr "   pages : $PAGES"
echoerr ""

if [ $show_all = 1 ]; then
  for ((i=1;i<=PAGES;i++)); do
    if [ $filter_org = 1 ]; then
      echoerr "Filtering page $i for org guid $ORG_GUID ..."
      curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/service_usage_events?results-per-page=100&order-direction=desc&page=$i" | jq ".resources[].entity | select(.org_guid == \"$ORG_GUID\")"
    else
      echoerr "Listing page $i ..."
      curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/service_usage_events?results-per-page=100&order-direction=desc&page=$i" | jq .
    fi
  done
else
  echoerr "Get service usage event #$1..."
  curl -sk -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/service_usage_events?results-per-page=1&page=$1"
fi
