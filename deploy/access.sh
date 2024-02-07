#!/bin/bash

sudo chmod -R 777 di_server_datbas/
sudo chmod -R 777 di_server_appl/

sudo chmod -R 777 di_indexupd_conf/
sudo chmod -R 777 di_indexupd_logs/

sudo chmod -R 777 di_webapp_conf/
sudo chmod -R 777 di_webapp_logs/

if [ -d "./di_scanners_workspace" ]; then
   sudo chmod -R 777 di_scanners_workspace/
fi   