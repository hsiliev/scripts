#!/bin/bash
set -e

SCRIPT_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$SCRIPT_DIR" ]]; then
  SCRIPT_DIR="$PWD";
fi

cf apps | tail -n +5 | awk '{print $1}' | xargs -n 1 $SCRIPT_DIR/restart-app.sh
