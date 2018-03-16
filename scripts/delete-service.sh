#!/bin/bash

set -e

cf delete-service -f $1
