#!/bin/bash

set -e

function show_help {
  cat << EOF
Usage: ${0##*/} [-hdb]

Deploy Abacus
  -h,-? display this help and exit
  -d    drop database
  -s    create and bind to DB service
  -c    copy config
EOF
}

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

  if [ -z "$APP_DOMAIN" ]; then
    echo "Unknown domain !"
    exit 1
  fi

  echo "Mapping $2 (0-$INSTANCES) instances of $APP_NAME in $APP_DOMAIN domain ..."
  for i in `seq 0 $INSTANCES`;
  do
    cf map-route "$APP_NAME-$i" $APP_DOMAIN --hostname "$APP_NAME"
  done
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
drop_database=0
db_service=0
copy_config=0

while getopts "h?dsc" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      d)  drop_database=1
        ;;
      s)  db_service=1
        ;;
      c)  copy_config=1
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "Arguments:"
echo "  drop_database='$drop_database'"
echo "  db_service='$db_service'"
echo "  copy_config='$copy_config'"
echo "  leftovers: $@"
echo ""

if [ $copy_config = 1 ]; then
  echo "Copying config ..."
  cp -R ~/workspace/abacus-config/* ~/workspace/cf-abacus
  echo ""
  echo "Rebuilding to apply config changes ..."
  echo ""
  cd ~/workspace/cf-abacus && npm run rebuild
fi

if [ $db_service = 1 ]; then
  set +e
  unbind-all-apps.sh db
  set -e
fi

echo ""
echo "Delete apps in parallel. We expect errors due to missing routes..."
set +e
delete-all-apps.sh
set -e
echo ""
echo "Delete apps. This time errors are NOT ok."
delete-all-apps.sh

if [ $drop_database = 1 ]; then
  echo ""
  echo "!!!! Dropping database in 5 seconds !!!!"
  echo ""
  echo "Interrupt this script with Ctrl-C to keep the DB intact"
  echo ""
  sleep 5s
  cf ds db -f
fi

npm run cfstage -- large
cf d -r -f abacus-pouchserver
cf d -r -f abacus-authserver-plugin

mapRoutes abacus-usage-collector 6
mapRoutes abacus-usage-reporting 6

if [ $drop_database = 1 ]; then
  echo "Creating new DB service instance ..."
  cf cs mongodb-beta v3.0-container db
fi

if [ $db_service = 1 ]; then
  bind-all-apps.sh db
fi

start-all-apps.sh
cf a

echo "Restarting failed apps ..."
restart-failed-apps.sh
cf a

echo ""
echo ""
echo "Deploy finished"
