#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-he] <query>

Get org usage
  -h,-? display this help and exit
  -e    encode query string
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h?e" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      e)
        encode=1
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Reading user id and secret from collector env..."
  CLIENT_ID=$(cf env ${ABACUS_PREFIX}abacus-applications-bridge | grep -w CLIENT_ID | awk '{ print $2 }')
  CLIENT_SECRET=$(cf env ${ABACUS_PREFIX}abacus-applications-bridge | grep -w CLIENT_SECRET | awk '{ print $2 }')
  echo ""
fi
if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Missing CLIENT_ID or CLIENT_SECRET !"
  exit 1
fi

if [ -z "$1" ]; then
  echo "No organization specified !"
  exit 1
fi
SCOPE="abacus.usage.read"
if [ -n "$RESOURCE_ID" ]; then
  SCOPE="abacus.usage.$RESOURCE_ID.read"
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $CLIENT_ID with scope $SCOPE from $AUTH_SERVER ..."
TOKEN=$(curl -k --user $CLIENT_ID:$CLIENT_SECRET -X POST -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo ""
  echo "No token found ! Running diagnostics request ..."
  echo ">>> curl -i -k --user $CLIENT_ID:$CLIENT_SECRET -s $AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE"
  curl -i -k --user $CLIENT_ID:$CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE"
  echo ""
  echo "Are your credentials (CLIENT_ID, CLIENT_SECRET and RESOURCE_ID) correct?"
  exit 1
fi
echo "Obtained token"
echo ""

echo "Getting current domain ..."
DOMAIN=$(cf domains | awk '{if (NR == 3) {print $1}}')
DOMAIN=${DOMAIN/cfapps/cf}
echo "Using domain $DOMAIN"
echo ""
if [ -z "$DOMAIN" ] || [ "$DOMAIN" == 'Failed' ]; then
  echo "No domain found ! Are your logged in CF?"
  exit 1
fi

DATE_IN_MS="$(date +%s000)"
URL="https://${ABACUS_PREFIX}abacus-usage-reporting.$DOMAIN/v1/metering/aggregated/usage/graph/"
if [[ $encode == 1 ]]; then
  echo "URI encoding query ..."
  QUERY=$(node -p "encodeURIComponent('$1')")
else
  QUERY=$1
fi

echo "Using $URL"
echo ""

echo "Getting report with query $1 from $URL ..."
echo ">>> curl -ksG -H 'Authorization: bearer $TOKEN' -H 'Content-Type: application/json' '$URL$QUERY' | jq ."
curl -ksG -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL$QUERY | jq .
