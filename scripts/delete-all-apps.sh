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

echo "Deleting applications ..."
for i in {1..5}; do
  (cf apps | tail -n +5 | awk '{print $1}' | xargs -P $PARALLEL_JOBS -n 1 $SCRIPT_DIR/delete-app.sh) && break || sleep 1;
done