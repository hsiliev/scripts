#!/bin/bash

set -e -x

delete-all-apps.sh
cf ds db -f

npm run cfstage -- large
cf d -r -f abacus-pouchserver
cf d -r -f abacus-authserver-plugin

cf cs mongodb-3.0.7-lite free db
bind-all-apps.sh db

start-all-apps.sh
