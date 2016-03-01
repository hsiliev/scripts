#!/bin/bash
set -x -e

API=$(cf api | cut -d ' ' -f 3)

curl -X POST -H "Authorization: $1" -i "$API/v2/app_usage_events/destructively_purge_all_and_reseed_started_apps"

