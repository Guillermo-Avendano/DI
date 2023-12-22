#!/bin/bash
docker build --network host -t rocketsoftware2024/di-webapp:10.00.002 -f dockerfile.tomcat .
docker image prune 
