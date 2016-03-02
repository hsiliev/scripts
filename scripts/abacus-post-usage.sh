#!/bin/bash
set -e

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
ORG_GUID=$(cf org $1 --guid)
echo "Done."
echo ""

echo "List spaces for org $1 ..."
SPACE=$(cf org abacus | awk '{ if (NR==7) {print $2}}')
echo "Get space $SPACE guid ..."
SPACE_GUID=$(cf space $SPACE --guid)
echo "Done."
echo ""

DATE_IN_MS=$(date +%s000)
BODY="{\"usage\":[{\"start\":$DATE_IN_MS,\"end\":$DATE_IN_MS,\"organization_id\":\"$ORG_GUID\",\"space_id\":\"$SPACE_GUID\",\"resource_id\":\"linux-container\",\"plan_id\":\"basic\",\"resource_instance_id\":\"1fb61c1f-2db3-4235-9934-00097845b80d\",\"measured_usage\":[{\"measure\":\"instance_memory\",\"quantity\":512},{\"measure\":\"running_instances\",\"quantity\":1}]}]}"
echo "Will submit usage $(echo $BODY | jq .)"
echo ""

curl -i -H "Authorization: bearer $TOKEN" -H "Content-Type: application/json" -X POST -d $BODY https://abacus-usage-collector.cfapps.sap.hana.ondemand.com/v1/metering/collected/usage
echo "Usage POSTed successfully"
