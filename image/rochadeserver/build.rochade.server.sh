#!/bin/bash
docker build --network host -t rocketsoftware2024/di-server:10.01.003 -f dockerfile.rochade.server .
docker image prune 
