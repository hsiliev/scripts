#!/bin/bash
set -e

PARALLEL_JOBS=10
if [ -n "$1" ]; then
  PARALLEL_JOBS=$1
fi

echo "Using $PARALLEL_JOBS parallel jobs ..."
cf apps | tail -n +5 | awk '{print $1}' | xargs -P $PARALLEL_JOBS -n 1 ~/scripts/start-app.sh
