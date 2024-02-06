#!/bin/bash
docker-compose up -d --remove-orphans

sudo chmod -R +r,+w di_server_datbas/
sudo chmod -R +r,+wdi_server_appl/

sudo chmod -R +r,+w di_indexupd_conf/
sudo chmod -R +r,+w di_indexupd_logs/

sudo chmod -R +r,+w di_webapp_conf/
sudo chmod -R +r,+w di_webapp_logs/

