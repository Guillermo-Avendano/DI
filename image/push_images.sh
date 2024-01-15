#!/bin/bash
docker login -u  rocketsoftware2024 -p Rocket2024
docker push rocketsoftware2024/di-solr:8.11.2
docker push rocketsoftware2024/di-indexupd:10.00.002
docker push rocketsoftware2024/di-webapp:10.00.002
docker push rocketsoftware2024/di-server:10.00.002
docker push rocketsoftware2024/di-db2empty:10.00.002
docker push rocketsoftware2024/di-db1empty:10.00.002
