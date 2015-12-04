#!/bin/bash

echo Flushing DNS cache ...
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
echo DNS Cache flushed
