#!/bin/bash

echo Flushing DNS cache ...
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
say cache flushed &
echo DNS Cache flushed
