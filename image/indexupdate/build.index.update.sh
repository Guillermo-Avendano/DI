#!/bin/bash
docker build --network host -t guillermoavendano/di-indexupd:10.00.002 -f dockerfile.index.update .
docker image prune 
