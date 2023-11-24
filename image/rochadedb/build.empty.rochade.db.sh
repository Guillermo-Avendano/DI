#!/bin/bash
docker build --network host -t guillermoavendano/di-db1empty:10.00.002 -f dockerfile.rochade.db1 .
docker build --network host -t guillermoavendano/di-db2empty:10.00.002 -f dockerfile.rochade.db2 .
docker image prune 
