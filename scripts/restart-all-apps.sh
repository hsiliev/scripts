#!/bin/bash

cf apps | tail -n +5 | awk '{print $1}' | xargs -n 1 ~/scripts/restart-app.sh
