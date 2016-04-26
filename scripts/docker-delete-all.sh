#!/bin/bash

echo "Delete all containers ..."
docker rm $(docker ps -a -q)

echo "Delete all images ..."
docker rmi $(docker images -q)
