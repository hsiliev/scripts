#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "No service specified !"
  exit 1;
fi

SERVICE=$1

cf apps | tail -n +5 | awk '{print $1}' | xargs -n 1 -P 20 ~/scripts/unbind-app.sh $SERVICE
