#!/bin/bash

echo "Delete all containers ..."
docker rm -fv $(docker ps -a -q)

echo "Delete all images ..."
docker rmi -f $(docker images -q)

echo "Delete all unused resources ..."
docker system prune --all --force --volumes
