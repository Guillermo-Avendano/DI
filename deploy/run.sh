#!/bin/bash

if [ ! -d "./di_server_datbas" ]; then
   docker-compose -f docker-compose.db.yaml up -d
fi

docker-compose up -d --remove-orphans
