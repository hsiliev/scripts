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

if [ -z "$ABACUS_CF_BRIDGE_CLIENT_ID" ] || [ -z "$ABACUS_CF_BRIDGE_CLIENT_SECRET" ]; then
  echo "Missing ABACUS_CF_BRIDGE_CLIENT_ID or ABACUS_CF_BRIDGE_CLIENT_SECRET !"
  exit 1
fi

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
show_all=0
filter_org=0
page=$1

while getopts "ha:f" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      a)
        show_all=1
        page=$OPTARG
        ;;
      f)
        filter_org=1
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "Arguments: show_all='$show_all', filter_org='$filter_org', page='$page', Leftovers: $@"
echo ""

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{print $3}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $ABACUS_CF_BRIDGE_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user "$ABACUS_CF_BRIDGE_CLIENT_ID:$ABACUS_CF_BRIDGE_CLIENT_SECRET" -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials" | jq -r .access_token)
if [ -z "$TOKEN" ]; then
  echo "No token found !"
  exit 1
fi
echo "Token obtained"
echo ""

echo "App usage events metadata:"
if [ $show_all = 1 ]; then
 curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000" | jq 'del(.resources)'
else
 curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=1" | jq 'del(.resources)'
fi
echo ""

if [ -z $page ]; then
  echo "No page specified !"
  exit 1
fi

if [ $show_all = 1 ]; then
  if [ $filter_org = 1 ]; then
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

    echo "Filtering page $page with 10000 usage events for org guid $ORG_GUID ..."
    curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000&page=$page" | jq ".resources[].entity | select(.org_guid == \"$ORG_GUID\")"
  else
    echo "Listing page $page with 10000 usage events ..."
    curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=10000&page=$page" | jq .
  fi
else
  echo "Get app usage event #$page..."
  curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" "$API/v2/app_usage_events?results-per-page=1&page=$page"
fi
