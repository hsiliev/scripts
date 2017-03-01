#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-ha] <organization name>

Get org usage
  -h,-? display this help and exit
  -a    display the whole report
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
show_all=0

while getopts "h?a" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      a)  show_all=1
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift


if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Missing CLIENT_ID or CLIENT_SECRET !"
  exit 1
fi
if [ -z "$1" ]; then
  echo "No organization specified !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl -k --user $CLIENT_ID:$CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=abacus.usage.read" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "No token found ! Are your credentials correct (CLIENT_ID and CLIENT_SECRET)?"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Get organization $1 guid ..."
set +e
ORG_GUID=$(cf org $1 --guid)
if [ $? != 0 ]; then
  echo "Organization $1 not found !"
  exit 1
fi
set -e
echo "Done."
echo ""

echo "Getting current domain ..."
DOMAIN=$(cf domains | awk '{if (NR == 3) {print $1}}')
echo "Using domain $DOMAIN"
echo ""
if [ -z "$DOMAIN" ]; then
  echo "No domain found ! Are your logged in CF?"
  exit 1
fi

URL="https://${ABACUS_PREFIX}abacus-usage-reporting.$DOMAIN/v1/metering/organizations/${ORG_GUID}/aggregated/usage"

echo "Using $URL"
echo ""

echo "Getting report for org $1 ($ORG_GUID) from $URL ..."
set +e
if [ $show_all == 1 ]; then
  OUTPUT=$(curl -k -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL | jq .)
else
  OUTPUT=$(curl -k -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL | jq .resources[0].plans[0].aggregated_usage[0])
fi
if [ "$OUTPUT" == "null" -o -z "$OUTPUT" ]; then
  echo ""
  echo "No report data! Getting original response:"
  curl -k -i -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL
else
  echo $OUTPUT | jq .
fi
