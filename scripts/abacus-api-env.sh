#!/bin/bash
set -e

cf set-env "$1" API https://api.cf.neo.ondemand.com
cf set-env "$1" UAA https://uaa.cf.neo.ondemand.com
cf restart "$1"
