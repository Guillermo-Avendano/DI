#!/bin/bash
docker build --network host -t guillermoavendano/di-webapp:10.00.002 -f dockerfile.tomcat .
docker image prune 
