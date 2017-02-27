#!/bin/bash

echo ""
echo "###"
echo "### Restarting app $1"
echo "###"

time cf restart $1

echo ""
echo "###"
echo "### Done restarting $1"
echo "###"
