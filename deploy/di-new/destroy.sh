#!/bin/bash
source .env

docker-compose -p $DI_PROJECT down -v

sudo rm -rf di_server_datbas/
sudo rm -rf di_server_appl/

sudo rm -rf di_indexupd_conf/
sudo rm -rf di_indexupd_logs/

sudo rm -rf di_webapp_conf/
sudo rm -rf di_webapp_logs/

