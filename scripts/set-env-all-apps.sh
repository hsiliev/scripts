#!/bin/bash

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

if [ "$#" -eq 2 ]; then
  echo "Listing all applications ..."
  cf apps | tail -n +5 | awk '{print $1}' | xargs -P 20 -n 1 $SCRIPT_DIR/set-env-app.sh $1 $2
else
  echo "Listing $1 applications ..."
  cf apps | tail -n +5 | awk '{print $1}' | grep -E $1 | xargs -P 20 -n 1 $SCRIPT_DIR/set-env-app.sh $2 $3
fi
