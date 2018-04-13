#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-ha] <plan id>

Get org usage
  -h,-? display this help and exit
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h?a" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Reading user id and secret from healthchecker env..."
  CLIENT_ID=$(cf env abacus-healthchecker | grep CLIENT_ID | awk '{ print $2 }')
  CLIENT_SECRET=$(cf env abacus-healthchecker | grep CLIENT_SECRET | awk '{ print $2 }')
  echo ""
fi

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Missing CLIENT_ID or CLIENT_SECRET !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting current domain ..."
DOMAIN=$(cf domains | awk '{if (NR == 3) {print $1}}')
DOMAIN=${DOMAIN/cfapps/cf}
echo "Using domain $DOMAIN"
echo ""
if [ -z "$DOMAIN" ]; then
  echo "No domain found ! Are your logged in CF?"
  exit 1
fi

URL="https://${ABACUS_PREFIX}abacus-healthchecker.$DOMAIN/v1/healthcheck"

echo "Getting health from $URL ..."
echo "curl -iks -u $CLIENT_ID:$CLIENT_SECRET -H \"Content-Type: application/json\" $URL"
OUTPUT=$(curl -ks -u $CLIENT_ID:$CLIENT_SECRET -H "Content-Type: application/json" $URL)
if [[ ! $OUTPUT =~ \{.*\} ]]; then
  echo ""
  echo "No health data! Getting original response:"
  curl -kis -u $CLIENT_ID:$CLIENT_SECRET -H "Content-Type: application/json" $URL | jq .
else
  echo $OUTPUT | jq .
fi
