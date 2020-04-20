#!/bin/bash
set -e

output=$(cf curl "/v2/apps?results-per-page=1&page=$1")

app_guid=$(echo $output | jq --raw-output ".resources[].metadata.guid")
entity=$(echo $output | jq --raw-output ".resources[].entity")

app_name=$(echo $entity | jq --raw-output .name)
space_url=$(echo $entity | jq --raw-output .space_url)
space_name=$(echo $entity | jq --raw-output .name)

org_url=$(cf curl $space_url | jq --raw-output .entity.organization_url)
org_name=$(cf curl $org_url | jq --raw-output .entity.name)

environment=$(cf curl /v2/apps/$app_guid/env | jq -c .)

echo "#$1" >&2;
echo "organization $org_name, space $space_name, app $app_name, env: $environment"
