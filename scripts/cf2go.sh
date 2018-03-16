#!/bin/bash

set -e

if [[ $2 == "jump" || $2 == "tunnel" || $2 == "scp" ]]; then
  cf2go --url="https://github.infra.hana.ondemand.com/raw/cloudfoundry/sofia-landscapes/master/sof-landscapes.json" "$@" --via-host=172.18.106.18
else
  cf2go --url="https://github.infra.hana.ondemand.com/raw/cloudfoundry/sofia-landscapes/master/sof-landscapes.json" "$@"
fi
