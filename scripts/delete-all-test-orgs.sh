#!/bin/bash

cf orgs | grep CATS | xargs -n 1 ~/scripts/delete-org.sh
