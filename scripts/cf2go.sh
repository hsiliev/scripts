#!/bin/bash

set -e

if [[ $1 == "jump" || $1 == "tunnel" || $1 == "scp" ]]; then
  cf2go "$@" --via-host=172.18.106.18
else
  cf2go "$@"
fi
