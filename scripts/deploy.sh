#!/bin/bash
set -e -x

DIR=${PWD}
if [ "$DIR" = "/Users/development/workspace/cf-release" ]; then
 MANIFEST=~/deployments/bosh-lite/cf.yml
fi
if [ "$DIR" = "/Users/development/workspace/diego-release" ]; then
 MANIFEST=~/deployments/bosh-lite/diego.yml
fi
if [ "$DIR" = "/Users/development/workspace/diego-docker-cache-release" ]; then
  MANIFEST=~/deployments/bosh-lite/docker-cache.yml
fi

gem cleanup
bosh target 192.168.50.4 lite
bosh -t lite -n create release --force
bosh -t lite -n upload release

if [ -n "$MANIFEST" ]; then
  bosh -t lite -n -d $MANIFEST deploy
else
  bosh -t lite -n deploy
fi

set +x

echo ""
echo ""
echo "************************************************"
echo "*************** Deploy completed ***************"
echo "************************************************"
echo ""
bosh -t lite -n cleanup
