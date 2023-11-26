#!/bin/bash
docker build --network host -t guillermoavendano/di-solr:8.11.2 -f dockerfile.solr .

docker image prune 
