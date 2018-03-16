#!/bin/bash

echo ""
echo "###"
echo "### Restaging app $1"
echo "###"

time cf restage $1

echo ""
echo "###"
echo "### Done restaging $1"
echo "###"
