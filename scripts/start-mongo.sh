#/bin/bash

set -e

if [ "$(uname)" == "Darwin" ]; then
  pushd /usr/local/var/mongodb
    rm -rf *
    mongod --config /usr/local/etc/mongod.conf
  popd
else
  pushd /var/lib/mongodb
    sudo rm -rf ./*
    sudo rm -rf *
    sudo service mongodb restart
  popd
fi
