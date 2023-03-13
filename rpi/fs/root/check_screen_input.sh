#!/bin/bash

while true; do
    if [ $(sudo timeout 2 tcpdump -i eth0 "port 1234" | wc -l) -gt 1 ]; then
        vcgencmd display_power 1 2
    else
        vcgencmd display_power 0 2
    fi
done
