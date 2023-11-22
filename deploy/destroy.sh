#!/bin/bash

docker-compose down -v
sudo rm -rf conf/ appl/ datbas/ solr_data/ idxupd_conf/ idxupd_logs/ tomcat_logs/  tomcat_conf/
