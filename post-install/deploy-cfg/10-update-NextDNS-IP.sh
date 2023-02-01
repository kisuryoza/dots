#! /usr/bin/bash

interface=$1 status=$2
case $status in
    up)
        curl https://link-ip.nextdns.io/dbf5cc/fab25000d44b0738 &> /dev/null &
        ;;
    down)
        ;;
esac

