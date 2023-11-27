#!/bin/bash
docker login -u avendano.guillermo@gmail.com
docker push guillermoavendano/di-solr:8.11.2         
docker push guillermoavendano/di-indexupd:10.00.002     
docker push guillermoavendano/di-webapp:10.00.002     
docker push guillermoavendano/di-server:10.00.002      
docker push guillermoavendano/di-db2empty:10.00.002      
docker push guillermoavendano/di-db1empty:10.00.002  