#!/bin/bash

set -e

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
  local FIRST_APP_NAME="$APP_NAME-0"
  local HOST_NAME=$APP_NAME
  if [ -n "$ABACUS_PREFIX" ]; then
    FIRST_APP_NAME="${ABACUS_PREFIX}${FIRST_APP_NAME}"
    HOST_NAME="${ABACUS_PREFIX}${HOST_NAME}"
  fi
  local INSTANCES=$(expr $2 - 1)
  local APP_URL=$(cf app $FIRST_APP_NAME | awk '{if (NR == 7) {print $2}}')
  local APP_DOMAIN=${APP_URL/$FIRST_APP_NAME./}

  if [ -z "$APP_DOMAIN" ]; then
    echo "Unknown domain for $FIRST_APP_NAME!"
    exit 1
  fi

  echo "Mapping $2 (0-$INSTANCES) instances of $APP_NAME in $APP_DOMAIN domain ..."
  for i in `seq 0 $INSTANCES`;
  do
    local FULL_APP_NAME=$APP_NAME-$i
    if [ -n "$ABACUS_PREFIX" ]; then
      FULL_APP_NAME="${ABACUS_PREFIX}${FULL_APP_NAME}"
    fi
    cf map-route $FULL_APP_NAME $APP_DOMAIN -n $HOST_NAME
  done
}

function show_help {
  cat << EOF
Usage: ${0##*/} [-hxudsbm] [-a <abacus_dir>] [-c <config_dir>] [-p <profile>]

Deploy and start Abacus instance
  -h,-?           display this help and exit
  -x              drop database service instance
  -u              undeploy applications
  -d              create database service instance
  -s              stage applications
  -b              bind database service instance to apps
  -m              map app routes
  -a <abacus_dir> abacus directory
  -c <config_dir> config directory
  -p <profile>    profile
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables
drop_database=0
create_database=0
undeploy_apps=0
stage_apps=0
bind_service=0
map_routes=0
profile="default"

while getopts "h?xudsbma:c:p:" opt; do
    case "$opt" in
      h|\?)
        show_help
        exit 0
        ;;
      x)  drop_database=1
        ;;
      u)  undeploy_apps=1
        ;;
      s)  stage_apps=1
        ;;
      d)  create_database=1
        ;;
      b)  bind_service=1
        ;;
      m)  map_routes=1
        ;;
      a)  abacus_dir="$OPTARG"
        ;;
      c)  config_dir="$OPTARG"
        ;;
      p)  profile="$OPTARG"
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ -z $abacus_dir ]; then
  abacus_dir=~/workspace/cf-abacus
fi

echo "Arguments:"
echo "  drop_database='$drop_database'"
echo "  undeploy_apps='$undeploy_apps'"
echo "  stage_apps='$stage_apps'"
echo "  create_database='$create_database'"
echo "  bind_service='$bind_service'"
echo "  map_routes='$map_routes'"
echo "  abacus_dir='$abacus_dir'"
echo "  config_dir='$config_dir'"
echo "  profile='$profile'"
echo "  leftovers: $@"
echo ""

if [ $drop_database = 1 ]; then
  set +e
  unbind-all-apps.sh db
  set -e
fi

if [ $undeploy_apps = 1 ]; then
  echo ""
  echo "Delete apps in parallel. We expect errors due to missing routes..."
  set +e
  delete-all-apps.sh
  set -e
  echo ""
  echo "Delete apps. This time errors are NOT ok."
  delete-all-apps.sh
fi

if [ $drop_database = 1 ]; then
  echo ""
  echo "!!!! Dropping database in 5 seconds !!!!"
  echo ""
  echo "Interrupt this script with Ctrl-C to keep the DB intact"
  echo ""
  sleep 5s
  cf ds db -f
  echo "Waiting for db service instance deletion ..."
  until cf service db | grep -q "Service instance db not found\|Status: create failed"
  do
    sleep 2s
  done
  echo "Done."
fi

if [ -n $config_dir ]; then
  echo "Copying config from $config_dir to $abacus_dir ..."
  pushd $config_dir
    echo "Abacus config branch in $config_dir:"
    git branch
  popd
  cp -R $config_dir/* $abacus_dir
  echo ""
  echo "Rebuilding to apply config changes ..."
  echo ""
  unset DB
  cd $abacus_dir && NO_ISTANBUL=true npm run rebuild
fi

if [ $stage_apps = 1 ]; then
  cd $abacus_dir && npm run cfstage -- $profile
fi

if [ $map_routes = 1 ]; then
  mapRoutes abacus-usage-collector 6
  mapRoutes abacus-usage-reporting 6
fi

if [ $create_database = 1 ]; then
  echo ""
  cf cs mongodb v3.0-dedicated-large db
  db_created=0
  until cf service db | grep -q 'Status: create succeeded'
  do
    sleep 2s
  done
  echo "DB created"
fi

if [ $bind_service = 1 ]; then
  bind-all-apps.sh db
fi

start-all-apps.sh
cf a

echo ""
echo "Restarting failed apps ..."
restart-failed-apps.sh
cf a

echo ""
echo ""
echo "Deploy finished"
