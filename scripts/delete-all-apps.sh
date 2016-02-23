#!/bin/bash

set -e

cf apps | tail -n +5 | awk '{print $1}' | xargs -P 20 -n 1 ~/scripts/delete-app.sh $1
