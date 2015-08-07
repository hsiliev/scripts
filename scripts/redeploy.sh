#!/bin/sh
$(dirname $0)/undeploy.sh $1
$(dirname $0)/deploy.sh
