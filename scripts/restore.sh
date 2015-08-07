#!/bin/sh

set -e -x

cd ~/workspace/bosh-lite
vagrant up

bin/add-route

echo "Waiting for BOSH to become active ..."
sleep 5

bosh target lite
bosh status

bosh -d ~/deployments/bosh-lite/cf.yml cck

bosh -d ~/deployments/bosh-lite/diego.yml cck

bosh -d ~/deployments/bosh-lite/docker-cache.yml cck

