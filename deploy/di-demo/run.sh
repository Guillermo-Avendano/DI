#!/bin/bash
source .env

if [ -z "$DI_LOCAL_IP" ]; then
   DI_LOCAL_IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | tail -n 1)
fi 

DI_SERVER_DATBAS=./di_server_datbas

if [ -z "$(ls -A "$DI_SERVER_DATBAS")" ] ; then
    echo "Rochade DB is not inicialized!"
    echo "run: ./init.sh"
else
    docker-compose -p $DI_PROJECT up -d --remove-orphans
fi

