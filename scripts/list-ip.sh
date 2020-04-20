#!/bin/bash
set -e

echo $1: $(cf ssh $1 -c 'bash -c "echo $CF_INSTANCE_ADDR"')
