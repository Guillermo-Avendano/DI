#!/bin/bash

sudo chmod -R 777 ./di_scanners_jenkins
sudo chmod -R 777 ./di_scanners_tomcat_logs

sudo rm -rf ./di_scanners_jenkins/workspace/scanners
sudo rm -rf ./di_scanners_jenkins/workspace/rrt
