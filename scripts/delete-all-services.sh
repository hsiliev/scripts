#!/bin/bash

set -e

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

PARALLEL_JOBS=1
if [ -n "$1" ]; then
  PARALLEL_JOBS=$1
fi

echo "Using $PARALLEL_JOBS parallel jobs."

echo "Deleting services ..."
cf services | tail -n +5 | awk '{print $1}' | xargs -P $PARALLEL_JOBS -n 1 $SCRIPT_DIR/delete-service.sh
