#!/bin/bash

if [ ! -d "./di_server_datbas" ]; then
   
   docker-compose -f docker-compose.db1.yaml up -d
   docker-compose -f docker-compose.db2.yaml up -d

   sudo chmod -R 777 di_server_datbas/
   
   DB_PATH=./di_server_datbas/
   for i in {1..3}; do
        md5=$(md5sum $DB_PATH/d1.rodb | awk '{print $1}')
        expected=$(cat $DB_PATH/d1.md5 | awk '{print $1}')
        if [ "$md5" == "$expected" ]; then
            echo "$DB_PATH/d1.rodb md5sum verified, attempt $i"
            d1=true
            break
        else
            echo "$DB_PATH/d1.rodb md5sum not verified, attempt $i"
            docker-compose -f docker-compose.db1.yaml up -d
        fi
   done

   # Verificar d2.rodb
   for i in {1..3}; do
        md5=$(md5sum $DB_PATH/d2.rodb | awk '{print $1}')
        expected=$(cat $DB_PATH/d2.md5 | awk '{print $1}')
        if [ "$md5" == "$expected" ]; then
            echo "$DB_PATH/d2.rodb md5sum verified, attempt $i"
            d2=true
            break
        else
            echo "$DB_PATH/d2.rodb md5sum not verified, attempt $i"
            docker-compose -f docker-compose.db2.yaml up -d

        fi
   done
fi

docker-compose up -d --remove-orphans
