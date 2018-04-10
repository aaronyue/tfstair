#!/bin/sh
LOCAL_IP=$(hostname -i)

if [ "$1" == "tair" ]; then

    sed -i "s/192.168.1.1/${LOCAL_IP}/g" /usr/local/tair/etc/*.conf

    /usr/local/tair/tair.sh start_ds && /usr/local/tair/tair.sh start_cs

    tail -200f /usr/local/tair/logs/server.log

elif [ "$1" = "tfs" ]; then
    sed -i "s/172.17.0.2/${LOCAL_IP}/g" /usr/local/tfs/conf/*.conf
    if [ ! -f "/data/tfs1/fs_super" ]; then
        /usr/local/tfs/scripts/stfs format 1
    fi
    /usr/local/tfs/scripts/tfs start_ns
    sleep 3
    /usr/local/tfs/scripts/tfs start_ds 1

    tail -f /usr/local/tfs/logs/dataserver_1.log
else
    exec "$@"
fi