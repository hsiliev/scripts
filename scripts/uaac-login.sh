#!/bin/bash

uaac target uaa.10.244.0.34.xip.io
uaac token client get admin -s admin-secret
uaac contexts
