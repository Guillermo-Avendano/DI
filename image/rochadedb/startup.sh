#!/bin/bash

cp /root/${DB}.rodb /home/rocket/rochade/datbas/${DB}.rodb 
cp /root/${DB}.md5 /home/rocket/rochade/datbas/${DB}.md5

chown -R 3003:0 /home/rocket/rochade/datbas
