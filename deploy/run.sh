#!/bin/bash
sudo mkdir -p conf/ appl/ datbas/ solr_data/ idxupd_conf/ idxupd_logs/ tomcat_logs/ tomcat_conf/
sudo chmod -R 777 conf/ appl/ datbas/ solr_data/ idxupd_conf/ idxupd_logs/ tomcat_logs/ tomcat_conf/
docker-compose up -d


