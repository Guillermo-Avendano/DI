#!/bin/bash
docker build --network host -t rocketsoftware2024/di-scanners:10.01.003 -f dockerfile.scanners .
docker image prune 
