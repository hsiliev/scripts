#!/bin/bash

set -e

SERVICE=$1

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

cf apps | tail -n +5 | awk '{print $1}' | xargs -P 20 -n 1 $SCRIPT_DIR/bind-app.sh $SERVICE
