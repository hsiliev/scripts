#!/bin/bash
set -e

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

echo "Listing applications ..."
cf apps | tail -n +5 | grep ? | awk '{print $1}' | xargs -P 5 -n 1 $SCRIPT_DIR/restart-app.sh

echo "Listing applications ..."
cf apps | tail -n +5 | grep -E ".*\s+0/\d+.*" | awk '{print $1}' | xargs -P 5 -n 1 $SCRIPT_DIR/restart-app.sh
