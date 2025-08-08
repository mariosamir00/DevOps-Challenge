#!/bin/sh

clear

#booting up the redis server
echo "Starting Redis server"
redis-server --daemonize yes

#wait for redis server to boot
echo "Waiting for Redis to initialize"
sleep 4 


exec "$@"