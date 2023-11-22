#!/bin/bash
docker build --network host -t guillermoavendano/di-server:10.00.002 -f dockerfile.rochade.server .
docker image prune 
