#!/bin/bash

set -e

cf unbind-service $2 $1
