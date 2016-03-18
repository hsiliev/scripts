#!/bin/bash

set -e -x

function mapRoutes {
  if [ -z "$1" ]; then
     echo "Cannot map app without a name !"
     exit 1
  fi
  if [ -z "$2" ]; then
    echo "Unknown number of instances !"
    exit 1
  fi

  local APP_NAME=$1
  local INSTANCES=$(expr $2 - 1)
  local APP_URL=$(cf app $APP_NAME-0 | awk '{if (NR == 7) {print $2}}')
  local APP_DOMAIN=${APP_URL/$APP_NAME-0./}

  echo "Mapping $INSTANCES of $APP_NAME in $APP_DOMAIN domain ..."
  for i in `seq 0 $INSTANCES`;
  do
    cf map-route "$APP_NAME-$i" $APP_DOMAIN --hostname "$APP_NAME"
  done
}

unbind-all-apps.sh db

echo "Delete apps in parallel. We expect errors due to missing routes..."
set +e
delete-all-apps.sh
set -e
echo "Delete apps. This time errors are not ok."
delete-all-apps.sh

if [ "$1" = "--dropDatabase" ]; then
  echo ""
  echo "!!!! Dropping database !!!!"
  echo ""
  sleep 5s
  cf ds db -f
fi

npm run cfstage -- large
cf d -r -f abacus-pouchserver
cf d -r -f abacus-authserver-plugin

mapRoutes abacus-usage-collector 6
mapRoutes abacus-usage-reporting 6

if [ "$1" = "--dropDatabase" ]; then
  echo "Creating new DB service instance ..."
  cf cs mongodb-3.0.7-lite free db
fi

echo "Building CF Bridge ..."
cd $HOME/workspace/cf-abacus/lib/cf/bridge
npm install
npm run babel
npm run lint
npm test
npm run cfpack
npm run cfpush

bind-all-apps.sh db
start-all-apps.sh
