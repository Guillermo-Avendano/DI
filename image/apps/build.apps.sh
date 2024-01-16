#!/bin/bash
docker build --network host -t rocketsoftware2024/di-apps:10.01.003 -f dockerfile.apps .
docker image prune 
