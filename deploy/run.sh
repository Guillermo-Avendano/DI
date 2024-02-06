#!/bin/bash
docker-compose up -d --remove-orphans

sudo chmod -R 775 di_server_datbas/
sudo chmod -R 775 di_server_appl/

sudo chmod -R 775 di_indexupd_conf/
sudo chmod -R 775 di_indexupd_logs/

sudo chmod -R 775 di_webapp_conf/
sudo chmod -R 775 di_webapp_logs/

sudo chmod -R 775 di_scanners_workspace/



