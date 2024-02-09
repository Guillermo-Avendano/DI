#!/bin/bash
md5sum ./datbas_demo/d1.rodb > ./datbas_demo/d1.md5
md5sum ./datbas_demo/d2.rodb > ./datbas_demo/d2.md5

docker build --network host -t rocketsoftware2024/di-db1demo:10.01.003 -f dockerfile.rochade.demo.db1 .
docker build --network host -t rocketsoftware2024/di-db2demo:10.01.003 -f dockerfile.rochade.demo.db2 .
docker image prune 
