#!/bin/bash
set -e

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

if [[ -z $PARALLEL_JOBS ]]; then
  PARALLEL_JOBS=200
fi
echo "Using $PARALLEL_JOBS parallel jobs."

if [ "$#" -eq 1 ]; then
  echo "Listing $1 applications ..."
  cf apps | tail -n +5 | awk '{print $1}' | grep -e $1 | xargs -P $PARALLEL_JOBS -n 1 $SCRIPT_DIR/start-app.sh
else
  echo "Listing $all applications ..."
  cf apps | tail -n +5 | awk '{print $1}' | xargs -P $PARALLEL_JOBS -n 1 $SCRIPT_DIR/start-app.sh
fi
