#!/bin/bash

tar -xzvf  /root/${DB}.tar.gz -C /home/rocket/rochade/datbas/ --strip-components=2

chown -R 3003:0 /home/rocket/rochade/datbas
