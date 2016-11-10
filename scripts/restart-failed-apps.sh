#!/bin/bash
set -e

cf apps | tail -n +5 | grep ? | awk '{print $1}' | xargs -P 5 -n 1 restart-app.sh
cf apps | tail -n +5 | grep 0/ | awk '{print $1}' | xargs -P 5 -n 1 restart-app.sh
