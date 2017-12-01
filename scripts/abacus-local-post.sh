#!/bin/bash

org_guid=$1
if [[ -z "$org_guid" ]]; then
  org_guid=34db180b-dc68-4305-bd95-a9af80ba7c4c
fi
echo "Using org $org_guid"

if [ -n "$SECURED" ]; then
  scope="abacus.usage.linux-container.read%20abacus.usage.linux-container.write"
  if [ ! -z "$RESOURCE_ID" ]; then
    scope="abacus.usage.$RESOURCE_ID.read%20abacus.usage.$RESOURCE_ID.write"
  fi

  echo "Getting token for scope $scope from local auth server ..."
  token=$(curl -k -X POST -s "http://localhost:9882/oauth/token?grant_type=client_credentials&scope=$scope" | jq -r .access_token)
  if [ "$token" == "null" ] || [ -z "$token" ]; then
    echo ""
    echo "No token found ! Running diagnostics ..."
    exit 1
  fi
  echo "Obtained token $token"
  echo ""
fi

date_in_ms=$(date +%s000)

# linux-container
#body="{\"start\":$date_in_ms,\"end\":$date_in_ms,\"organization_id\":\"$org_guid\",\"space_id\":\"2\",\"resource_id\":\"linux-container\",\"plan_id\":\"basic\",\"consumer_id\":\"app:1fb61c1f-2db3-4235-9934-00097845b80d\",\"resource_instance_id\":\"1fb61c1f-2db3-4235-9934-00097845b80d\",\"measured_usage\":[{\"measure\":\"current_instance_memory\",\"quantity\":512},{\"measure\":\"current_running_instances\",\"quantity\":1},{\"measure\":\"previous_instance_memory\",\"quantity\":0},{\"measure\":\"previous_running_instances\",\"quantity\":0}]}"

body="{\"start\":$date_in_ms,\"end\":$date_in_ms,\"organization_id\":\"$org_guid\",\"space_id\":\"na\",\"consumer_id\":\"na\",\"resource_id\":\"object-storage\",\"plan_id\":\"basic\",\"resource_instance_id\":\"na\",\"measured_usage\":[{\"measure\": \"storage\",\"quantity\":1}]}"

# object-storage
# body="{\"start\":$date_in_ms,\"end\":$date_in_ms,\"organization_id\":\"$org_guid\",\"space_id\":\"aaeae239-f3f8-483c-9dd0-de5d41c38b6a\",\"consumer_id\":\"app:bbeae239-f3f8-483c-9dd0-de6781c38bab\",\"resource_id\":\"object-storage\",\"plan_id\":\"basic\",\"resource_instance_id\":\"0b39fa70-a65f-4183-bae8-385633ca5c87\",\"measured_usage\":[{\"measure\": \"storage\",\"quantity\":1073741824},{\"measure\":\"light_api_calls\",\"quantity\":1000}, {\"measure\":\"heavy_api_calls\",\"quantity\": 100}]}"

# service
# body="{\"start\":$date_in_ms,\"end\":$date_in_ms,\"organization_id\":\"$org_guid\",\"space_id\":\"baeae239-f3f8-483c-9dd0-de5d41c38b7c\",\"consumer_id\":\"service:qwe123\",\"resource_id\":\"redis\",\"plan_id\":\"medium\",\"resource_instance_id\":\"service:redis:medium:qwe123\",\"measured_usage\":[{\"measure\":\"current_instances\",\"quantity\":1},{\"measure\":\"previous_instances\",\"quantity\":0}]}"

url="http://localhost:9080/v1/metering/collected/usage"

echo "Posting $body to $url ..."
if [ -n "$SECURED" ]; then
  curl -i -H "Authorization: bearer $token" -H "Content-Type: application/json" -X POST -d "$body" "$url"
else
  curl -i -H "Content-Type: application/json" -X POST -d "$body" "$url"
fi
