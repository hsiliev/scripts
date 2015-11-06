#!/bin/bash
set -e -x

cf api --skip-ssl-validation api.bosh-lite.com
cf auth admin admin
cf create-org diego
cf target -o diego
cf create-space diego
cf target -s diego
