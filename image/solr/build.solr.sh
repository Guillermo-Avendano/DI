#!/bin/bash
docker build --network host -t rocketsoftware2024/di-solr:8.11.2 -f dockerfile.solr .

docker image prune 
