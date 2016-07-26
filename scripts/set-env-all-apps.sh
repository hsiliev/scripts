#!/bin/bash

cf apps | tail -n +5 | awk '{print $1}' | xargs -n 1 ~/scripts/set-env-app.sh $1 $2
