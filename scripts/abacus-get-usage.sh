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
API=$(cf api | awk '{print $3}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl --user $CLIENT_ID:$CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=abacus.usage.linux-container.write%20abacus.usage.linux-container.read" | jq -r .access_token)
if [ "$TOKEN" == "null" ]; then
  echo "No token found !"
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

echo "Getting abacus-usage-reporting URL ..."
URL=$(cf app abacus-usage-reporting | awk '{if (NR == 7) {print $2}}')
if [ -z "$URL" ]; then
  echo "Cannot find URL! Have you targeted abacus org/space?"
  exit 1
fi
URL="https://$URL/v1/metering/organizations/${ORG_GUID}/aggregated/usage"
echo "Using $URL"
echo ""

echo "Getting report for org $1 ($ORG_GUID) from $URL ..."
set +e
if [ $show_all == 1 ]; then
  OUTPUT=$(curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL | jq .)
else
  OUTPUT=$(curl -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL | jq .resources[0].plans[0].aggregated_usage[0])
fi
if [ "$OUTPUT" == "null" -o -z "$OUTPUT" ]; then
  echo ""
  echo "No report data! Getting original response:"
  curl -i -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL
else
  echo $OUTPUT | jq .
fi
