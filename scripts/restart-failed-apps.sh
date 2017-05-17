#!/bin/bash
set -e

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

PARALLEL_JOBS=5
if [ -n "$1" ]; then
  PARALLEL_JOBS=$1
fi

echo "Using $PARALLEL_JOBS parallel jobs."

echo "Listing applications ..."
cf apps | tail -n +5 | grep ? | awk '{print $1}' | xargs -P ${PARALLEL_JOBS} -n 1 ${SCRIPT_DIR}/restart-app.sh

echo "Listing applications ..."
cf apps | tail -n +5 | grep 0/ | awk '{print $1}' | xargs -P ${PARALLEL_JOBS} -n 1 ${SCRIPT_DIR}/restart-app.sh
