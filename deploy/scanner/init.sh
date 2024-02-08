#!/bin/bash
docker-compose up -d --remove-orphans
sleep 3

docker exec mssql2017 /opt/mssql-tools/bin/sqlcmd -U sa -P "Rocket2023" -i /samples/pubs_db.sql
docker exec mssql2017 /opt/mssql-tools/bin/sqlcmd -U sa -P "Rocket2023" -i /samples/northwind_db.sql

sudo chmod -R 777 ./di_scanners_jobs
sudo chmod -R 777 ./di_scanners_workspace
sudo chmod -R 777 ./di_scanners_tomcat_logs

