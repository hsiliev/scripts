#!/bin/bash

docker-machine create -d virtualbox --engine-env HTTP_PROXY=http://proxy:8080 --engine-env HTTPS_PROXY=https://proxy:8080 proxy
