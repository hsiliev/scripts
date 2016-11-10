#!/bin/bash

cf orgs | grep CATS | xargs -n 1 delete-org.sh
