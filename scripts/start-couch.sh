#/bin/bash

set -e

pushd /usr/local/var/lib/couchdb
  rm -rf *
  couchdb
popd
