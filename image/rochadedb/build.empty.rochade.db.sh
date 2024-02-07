#!/bin/bash
md5sum ./datbas_empty/d1.rodb > ./datbas_empty/d1.md5
md5sum ./datbas_empty/d2.rodb > ./datbas_empty/d2.md5

docker build --network host -t rocketsoftware2024/di-db1empty:10.01.003 -f dockerfile.rochade.db1 .
docker build --network host -t rocketsoftware2024/di-db2empty:10.01.003 -f dockerfile.rochade.db2 .
docker image prune 
