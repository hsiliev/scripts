#/bin/bash

set -e

if [ "$(uname)" == "Darwin" ]; then
  pushd /usr/local/var/lib/couchdb
    rm -rf *
    couchdb
  popd
else
  sudo chmod 755 /var/lib/couchdb
  pushd /var/lib/couchdb
    sudo rm -rf ./*
    sudo rm -rf *
  popd
  sudo chmod 750 /var/lib/couchdb
  sudo service couchdb restart
fi
