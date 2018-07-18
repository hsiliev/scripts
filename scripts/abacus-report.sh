#!/bin/bash
set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-ha] <organization name>

Get org usage
  -h,-? display this help and exit
EOF
}

function errcho {
  >&2 echo $1
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
  errcho "Reading system user id and secret ..."
  cf target -o SAP_abacus -s abacus
  CLIENT_ID=$(cf env abacus-usage-collector | grep CLIENT_ID | awk '{ print $2 }')
  CLIENT_SECRET=$(cf env abacus-usage-collector | grep CLIENT_SECRET | awk '{ print $2 }')
  errcho ""
fi

if [ -z "$1" ]; then
  errcho "No organization specified !"
  exit 1
fi

SCOPE="abacus.usage.read"
if [ -n "$RESOURCE_ID" ]; then
  SCOPE="abacus.usage.$RESOURCE_ID.read"
fi

errcho "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
errcho "Using API URL $API"
errcho ""

errcho "Getting token for $CLIENT_ID with scope $SCOPE from $AUTH_SERVER ..."
echo ">>> curl -k --user $CLIENT_ID:$CLIENT_SECRET -X POST -s '$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE'"
TOKEN=$(curl -k --user $CLIENT_ID:$CLIENT_SECRET -X POST -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  errcho ""
  errcho "No token found ! Running diagnostics request ..."
  errcho ">>> curl -i -k --user $CLIENT_ID:$CLIENT_SECRET -s $AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE"
  curl -i -k --user $CLIENT_ID:$CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE"
  errcho ""
  errcho "Are your credentials (CLIENT_ID, CLIENT_SECRET and RESOURCE_ID) correct?"
  exit 1
fi
errcho "Obtained token"
errcho ""

errcho "Get organization $1 guid ..."
set +e
ORG_GUID=$(cf org $1 --guid)
if [ $? != 0 ]; then
  errcho "Assuming $1 is org's GUID ..."
  ORG_GUID=$1
fi
set -e
errcho "Done."
errcho ""

errcho "Getting current domain ..."
DOMAIN=$(cf domains | awk '{if (NR == 3) {print $1}}')
DOMAIN=${DOMAIN/cfapps/cf}
errcho "Using domain $DOMAIN"
errcho ""
if [ -z "$DOMAIN" ] || [ "$DOMAIN" == 'Failed' ]; then
  errcho "No domain found ! Are your logged in CF?"
  exit 1
fi

if [[ -z $DATE_IN_MS ]]; then
  DATE_IN_MS="$(date +%s000)"
fi
URL="https://${ABACUS_PREFIX}abacus-usage-reporting.$DOMAIN/v1/metering/organizations/${ORG_GUID}/aggregated/usage/$DATE_IN_MS"

errcho "Using $URL"
errcho ""

errcho "Getting report for org $1 ($ORG_GUID) from $URL ..."
errcho ">>> curl -k -H 'Authorization: bearer $TOKEN' -H 'Content-Type: application/json' $URL | jq ."
curl -k -s -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" $URL | jq .
