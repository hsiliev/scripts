#!/bin/bash

set -e

du -a /var | sort -n -r | head -n 10
