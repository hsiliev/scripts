#!/bin/bash

set -e

set -e

if [ "$(uname)" == "Darwin" ]; then
  rabbitmq-server
else
  sudo service rabbitmq-server restart
fi
