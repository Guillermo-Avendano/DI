#!/bin/bash
md5sum ./datbas_demo/d1.rodb > ./datbas_demo/d1.md5
md5sum ./datbas_demo/d2.rodb > ./datbas_demo/d2.md5

tar -czvf ./datbas_demo/d1.tar.gz ./datbas_demo/d1.rodb ./datbas_demo/d1.md5
tar -czvf ./datbas_demo/d2.tar.gz ./datbas_demo/d2.rodb ./datbas_demo/d2.md5

docker buildx build --network host -t rocketsoftware2024/di-db1demo:10.01.003 -f dockerfile.rochade.demo.db1 .
docker buildx build --network host -t rocketsoftware2024/di-db2demo:10.01.003 -f dockerfile.rochade.demo.db2 .

docker image prune 
