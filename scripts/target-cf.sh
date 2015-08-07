#/bin/bash
set -e -x

cf api --skip-ssl-validation api.10.244.0.34.xip.io
cf auth admin admin
cf create-org diego
cf target -o diego
cf create-space diego
cf target -s diego
