#!/bin/bash

echo Flushing DNS cache ...
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
say -v h cache flushed &
echo DNS Cache flushed
