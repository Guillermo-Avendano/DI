#!/bin/bash
docker build --network host -t rocketsoftware2024/di-indexupd:8.11.2 -f dockerfile.index.update .
docker image prune 
