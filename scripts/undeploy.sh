#!/bin/bash

bosh target 192.168.50.4
bosh -n delete deployment $1 --force
bosh -n delete release $1 --force
