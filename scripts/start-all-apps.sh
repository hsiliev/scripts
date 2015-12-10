#!/bin/bash
set -e

cf apps | tail -n +5 | awk '{print $1}' | xargs -P 5 -n 1 ~/scripts/start-app.sh
