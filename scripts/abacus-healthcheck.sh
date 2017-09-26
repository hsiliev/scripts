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
OUTPUT=$(curl -ks -u $HYSTRIX_CLIENT_ID:$HYSTRIX_CLIENT_SECRET -H "Content-Type: application/json" $URL)
if [[ ! $OUTPUT =~ \{.*\} ]]; then
  echo ""
  echo "No health data! Getting original response:"
  curl -kis -u $HYSTRIX_CLIENT_ID:$HYSTRIX_CLIENT_SECRET -H "Content-Type: application/json" $URL
else
  echo $OUTPUT | jq .
fi
