#!/bin/bash
set -e

cf apps | tail -n +5 | awk '{print $1}' | xargs -P 10 -n 1 stop-app.sh
