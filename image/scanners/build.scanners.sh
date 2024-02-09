#!/bin/bash

rm jenkins.tar.gz
tar -czvf jenkins.tar.gz .jenkins
docker build --network host -t rocketsoftware2024/di-scanners:10.01.003 -f dockerfile.scanners .
docker image prune 
