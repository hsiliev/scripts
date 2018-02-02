#!/bin/bash

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

echo "Listing applications ..."
cf apps | tail -n +5 | awk '{print $1}' | xargs -P 20 -n 1 ${SCRIPT_DIR}/list-env-app.sh
