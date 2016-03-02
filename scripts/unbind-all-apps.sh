#!/bin/bash

set -e

SERVICE=$1

cf apps | tail -n +5 | awk '{print $1}' | xargs -n 1 ~/scripts/unbind-app.sh $SERVICE
