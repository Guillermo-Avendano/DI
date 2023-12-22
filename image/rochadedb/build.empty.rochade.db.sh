#!/bin/bash
docker build --network host -t rocketsoftware2024/di-db1empty:10.00.002 -f dockerfile.rochade.db1 .
docker build --network host -t rocketsoftware2024/di-db2empty:10.00.002 -f dockerfile.rochade.db2 .
docker image prune 
