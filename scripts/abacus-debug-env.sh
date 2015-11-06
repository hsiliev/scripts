#!/bin/bash
set -e

cf set-env "$1" DEBUG "abacus-*"
cf restart "$1"
