#!/bin/bash

DI_SERVER_DATBAS=./di_server_datbas

if [ -z "$(ls -A "$DI_SERVER_DATBAS")" ] ; then
    echo "Rochade DB not inicialized!"
else
    docker-compose up -d --remove-orphans
fi

