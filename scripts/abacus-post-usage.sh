#!/bin/bash

set -e

if [ -z "$1" ] && [ -z $ORG_GUID ]; then
  echo "No organization specified !"
  exit 1
fi
SCOPE="abacus.usage.write"
if [ -n "$RESOURCE_ID" ]; then
  SCOPE="abacus.usage.$RESOURCE_ID.write"
fi

echo "Obtaining API endpoint URL ..."
API=$(cf api | awk '{if (NR == 1) {print $3}}')
AUTH_SERVER=${API/api./uaa.}
echo "Using API URL $API"
echo ""

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
  echo "Reading user id and secret from collector env..."
  CLIENT_ID=$(cf env ${ABACUS_PREFIX}abacus-applications-bridge | grep -w CLIENT_ID | awk '{ print $2 }')
  CLIENT_SECRET=$(cf env ${ABACUS_PREFIX}abacus-applications-bridge | grep -w CLIENT_SECRET | awk '{ print $2 }')
  echo ""
fi

echo "Getting token for $CLIENT_ID with scope $SCOPE from $AUTH_SERVER ..."
TOKEN=$(curl --user $CLIENT_ID:$CLIENT_SECRET -s "$AUTH_SERVER/oauth/token?grant_type=client_credentials&scope=$SCOPE" | jq -r .access_token)
if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "No token found ! Are your credentials correct (CLIENT_ID and CLIENT_SECRET)?"
  exit 1
fi
echo "Token obtained"
echo ""

echo "Getting first CF domain ..."
DOMAIN=$(cf domains | awk '{if (NR == 3) {print $1}}')
DOMAIN=${DOMAIN/cfapps/cf}
echo "Using domain $DOMAIN"
echo ""
if [ -z "$DOMAIN" ]; then
  echo "No domain found ! Are your logged in CF?"
  exit 1
fi

echo "Getting abacus-usage-collector URL ..."
URL="https://${ABACUS_PREFIX}abacus-usage-collector.$DOMAIN/v1/metering/collected/usage"

echo "Using $URL"
echo ""

if [[ -z $ORG_GUID ]]; then
  echo "Get organization $1 and space info ..."
  set +e
  ORG_GUID=$(cf org $1 --guid)
  if [ $? != 0 ]; then
    echo "Assuming $1 is org's GUID ..."
    ORG_GUID=$1
  else
    echo "List spaces for org $1 ..."
    SPACE=$(cf org $1 | awk '{ if (NR==7) {print $2}}')
    echo "Get space $SPACE guid ..."
    SPACE_GUID=$(cf space $SPACE --guid)
    echo "Done."
    echo ""
  fi
  set -e
  echo "Done."
  echo ""
fi

if [[ -z $SPACE_GUID ]]; then
  SPACE_GUID=1
fi

if [[ -z $DATE_IN_MS ]]; then
  DATE_IN_MS="$(date +%s000)"
fi

BODY="{\"start\":$DATE_IN_MS,\"end\":$DATE_IN_MS,\"organization_id\":\"$ORG_GUID\",\"space_id\":\"$SPACE_GUID\",\"resource_id\":\"iotae\",\"plan_id\":\"basic\",\"consumer_id\":\"app:1fb61c1f-2db3-4235-9934-00097845b80d\",\"resource_instance_id\":\"1fb61c1f-2db3-4235-9934-00097845b80d\",\"measured_usage\":[{\"measure\":\"warm_store\",\"quantity\":7},{\"measure\":\"cold_store\",\"quantity\":7},{\"measure\":\"aggregate_store\",\"quantity\":7},{\"measure\":\"api_calls\",\"quantity\":7}]}"
BODY="{\"start\":$DATE_IN_MS,\"end\":$DATE_IN_MS,\"organization_id\":\"$ORG_GUID\",\"space_id\":\"$SPACE_GUID\",\"consumer_id\":\"na\",\"resource_id\":\"1dc0754a-fdaf-4da7-89a1-d10124a5068c\",\"plan_id\":\"1dc0754a-fdaf-4da7-89a1-d10124a5068c-1dc0754a-fdaf-4da7-89a1-d10124a5068c\",\"resource_instance_id\":\"73109c5e-76ae-40db-843a-7ab234abadfd\",\"measured_usage\":[{\"measure\":\"api_calls\",\"quantity\":3545}]}"
BODY="{\"start\":$DATE_IN_MS,\"end\":$DATE_IN_MS,\"organization_id\":\"$ORG_GUID\",\"space_id\":\"$SPACE_GUID\",\"resource_id\":\"linux-container\",\"plan_id\":\"basic\",\"consumer_id\":\"app:cb5c53de-42fb-40de-a54a-8053210b55c6\",\"resource_instance_id\":\"memory:cb5c53de-42fb-40de-a54a-8053210b55c6\",\"measured_usage\":[{\"measure\":\"current_instance_memory\",\"quantity\":268435456},{\"measure\":\"current_running_instances\",\"quantity\":100},{\"measure\":\"previous_instance_memory\",\"quantity\":0},{\"measure\":\"previous_running_instances\",\"quantity\":0}]}"

echo ">>> curl -i -H 'Authorization: bearer $TOKEN' -H 'Content-Type: application/json' -X POST -d $BODY $URL"
curl -i -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" -X POST -d $BODY $URL
