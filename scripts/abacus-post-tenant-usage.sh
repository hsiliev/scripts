#!/bin/bash

set -e

DATE_IN_MS=$(date +%s000)
TENANT1="{\"start\":$DATE_IN_MS,\"end\":$DATE_IN_MS,\"organization_id\":\"1\",\"space_id\":\"1\",\"resource_id\":\"object-storage\",\"plan_id\":\"basic\",\"consumer_id\":\"tenant:1\",\"resource_instance_id\":\"1\",\"measured_usage\":[{\"measure\":\"storage\",\"quantity\":1},{\"measure\":\"light_api_calls\",\"quantity\":1},{\"measure\":\"heavy_api_calls\",\"quantity\":0}]}"
TENANT2="{\"start\":$DATE_IN_MS,\"end\":$DATE_IN_MS,\"organization_id\":\"1\",\"space_id\":\"1\",\"resource_id\":\"object-storage\",\"plan_id\":\"basic\",\"consumer_id\":\"tenant:2\",\"resource_instance_id\":\"1\",\"measured_usage\":[{\"measure\":\"storage\",\"quantity\":1},{\"measure\":\"light_api_calls\",\"quantity\":1},{\"measure\":\"heavy_api_calls\",\"quantity\":0}]}"

echo "POSTing usage for tenant #1 and #2 ..."
curl -i -H "Content-Type: application/json" -X POST -d $TENANT1 http://localhost:9080/v1/metering/collected/usage
curl -i -H "Content-Type: application/json" -X POST -d $TENANT2 http://localhost:9080/v1/metering/collected/usage

echo "Sleeping 5 seconds to allow the usage to be calculated ..."
sleep 5s

echo "Getting usage report ..."
echo ""
curl -H "Content-Type: application/json" http://localhost:9088/v1/metering/organizations/1/aggregated/usage | jq .spaces[0].consumers