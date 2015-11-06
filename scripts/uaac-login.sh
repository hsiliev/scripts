#!/bin/bash
set -e

uaac target --skip-ssl-validation https://uaa.bosh-lite.com
uaac token client get admin -s admin-secret
uaac contexts
