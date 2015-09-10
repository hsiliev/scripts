#!/bin/bash

set -e -x

STEMCELL_SOURCE=http://bosh-jenkins-artifacts.s3.amazonaws.com/bosh-stemcell/warden
STEMCELL_FILE=latest-bosh-stemcell-warden.tgz

bosh target 192.168.50.4 lite

pushd ~/workspace
  wget --progress=bar -c "${STEMCELL_SOURCE}/${STEMCELL_FILE}" -O "$STEMCELL_FILE"
  bosh -t lite -n -u admin -p admin upload stemcell --skip-if-exists $STEMCELL_FILE  
popd

pushd ~/workspace/diego-release
  bosh target lite
  mkdir -p ~/deployments/bosh-lite
  cd ~/workspace/diego-release
  ./scripts/print-director-stub > ~/deployments/bosh-lite/director.yml
popd

pushd ~/workspace/cf-release
  ./scripts/generate_deployment_manifest warden \
      ~/deployments/bosh-lite/director.yml \
      ~/workspace/diego-release/stubs-for-cf-release/enable_consul_with_cf.yml \
      ~/workspace/diego-release/stubs-for-cf-release/enable_diego_ssh_in_cf.yml \
      > ~/deployments/bosh-lite/cf.yml
  bosh create release --force && bosh -t lite -n upload release && bosh -t lite -d ~/deployments/bosh-lite/cf.yml -n deploy
popd

cf api --skip-ssl-validation api.10.244.0.34.xip.io
cf auth admin admin
cf enable-feature-flag diego_docker

bosh upload release https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release --skip-if-exists || true

pushd ~/workspace/diego-release
  ./scripts/generate-deployment-manifest \
      ~/deployments/bosh-lite/director.yml \
      ~/workspace/diego-docker-cache-release/stubs-for-diego-release/bosh-lite-property-overrides.yml \
      manifest-generation/bosh-lite-stubs/instance-count-overrides.yml \
      manifest-generation/bosh-lite-stubs/persistent-disk-overrides.yml \
      manifest-generation/bosh-lite-stubs/iaas-settings.yml \
      manifest-generation/bosh-lite-stubs/additional-jobs.yml \
      ~/deployments/bosh-lite \
      > ~/deployments/bosh-lite/diego.yml
  bosh create release --force && bosh -t lite -n upload release && bosh -t lite -d ~/deployments/bosh-lite/diego.yml -n deploy
popd

pushd ~/workspace/diego-docker-cache-release
   ./scripts/generate-deployment-manifest ~/deployments/bosh-lite/director.yml \
       manifest-generation/bosh-lite-stubs/property-overrides.yml \
       manifest-generation/bosh-lite-stubs/instance-count-overrides.yml \
       manifest-generation/bosh-lite-stubs/persistent-disk-overrides.yml \
       manifest-generation/bosh-lite-stubs/iaas-settings.yml \
       manifest-generation/bosh-lite-stubs/additional-jobs.yml \
       ~/deployments/bosh-lite \
       > ~/deployments/bosh-lite/docker-cache.yml
  bosh create release --force && bosh -t lite -n upload release && bosh -t lite -d ~/deployments/bosh-lite/docker-cache.yml -n deploy
popd
