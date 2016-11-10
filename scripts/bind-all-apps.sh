#!/bin/bash

set -e

SERVICE=$1

cf apps | tail -n +5 | awk '{print $1}' | xargs -P 20 -n 1 bind-app.sh $SERVICE
