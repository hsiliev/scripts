#/bin/bash

set -e

pushd /usr/local/var/mongodb
  rm -rf *
  mongod --config /usr/local/etc/mongod.conf
popd
