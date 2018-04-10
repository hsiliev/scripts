#!/bin/bash

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

if [ "$#" -eq 1 ]; then
  echo "Listing all applications ..."
  cf apps | tail -n +5 | awk '{print $1}' | xargs -P 20 -n 1 $SCRIPT_DIR/unset-env-app.sh $1
else
  echo "Listing $1 applications ..."
  cf apps | tail -n +5 | awk '{print $1}' | grep -e $1 | xargs -P 20 -n 1 $SCRIPT_DIR/unset-env-app.sh $2
fi
