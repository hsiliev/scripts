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

if [ -z "$HYSTRIX_CLIENT_ID" ] || [ -z "$HYSTRIX_CLIENT_SECRET" ]; then
  echo "Missing HYSTRIX_CLIENT_ID or HYSTRIX_CLIENT_SECRET !"
  exit 1
fi
if [ -z "$1" ]; then
  echo "No plan id specified !"
  exit 1
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

echo "Getting token for $HYSTRIX_CLIENT_ID from $AUTH_SERVER ..."
TOKEN=$(curl -k --user $HYSTRIX_CLIENT_ID:$HYSTRIX_CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=abacus.system.read" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo ""
  echo "No token found ! Running diagnostics ..."
  set -x
  curl -i -k --user $HYSTRIX_CLIENT_ID:$HYSTRIX_CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=abacus.system.read"
  set +x
  echo ""
  echo "Are your credentials correct (HYSTRIX_CLIENT_ID and HYSTRIX_CLIENT_SECRET)?"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Getting current domain ..."
DOMAIN=$(cf domains | awk '{if (NR == 3) {print $1}}')
echo "Using domain $DOMAIN"
echo ""
if [ -z "$DOMAIN" ]; then
  echo "No domain found ! Are your logged in CF?"
  exit 1
fi

URL="https://${ABACUS_PREFIX}$1.$DOMAIN/healthcheck"

echo "Getting health for $1 ..."
OUTPUT=$(curl -k -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL)
if [[ ! $OUTPUT =~ \{.*\} ]]; then
  echo ""
  echo "No health data! Getting original response:"
  curl -k -i -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL
else
  echo $OUTPUT | jq .
fi
