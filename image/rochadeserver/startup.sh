#!/bin/bash

replace_tag_in_file() {
    local filename=$1
    local search=$2
    local replace=$3

    if [[ $search != "" ]]; then
        # Escape not allowed characters in sed tool
        search=$(printf '%s\n' "$search" | sed -e 's/[]\/$*.^[]/\\&/g');
        replace=$(printf '%s\n' "$replace" | sed -e 's/[]\/$*.^[]/\\&/g');
        sed -i'' -e "s/$search/$replace/g" $filename
    fi
}

# $RO_LICENSE, $RO_COMPANY are environment variables comming from image's environment variables

RO_CONF="/home/rocket/rochade/conf"
RO_APPL="/home/rocket/rochade/appl"
RO_DATBAS="/home/rocket/rochade/datbas"

if [ -z "$(ls -A "$RO_CONF")" ] && [ -z "$(ls -A "$RO_APPL")" ] && [ -z "$(ls -A "$RO_DATBAS")" ]; then
   cp /home/rocket/rochade/conf_template/*.* /home/rocket/rochade/conf
   cp /home/rocket/rochade/appl_template/*.* /home/rocket/rochade/appl
fi

replace_tag_in_file /home/rocket/rochade/appl/server.ini "#RO_LICENSE#" $RO_LICENSE
replace_tag_in_file /home/rocket/rochade/appl/server.ini "#RO_COMPANY#" "$RO_COMPANY"

cd /home/rocket/rochade/sbin

./roserver.sh

nohup java -cp "/home/rocket/rochade/h2bin/*:/home/rocket/rochade/h2bin/h2.jar" org.h2.tools.Server -tcp -tcpAllowOthers -tcpPort 9092 -tcpPassword H24Camunda4Rochade -ifNotExists -baseDir "/home/rocket/rochade/datbas/" &>>/home/rocket/rochade/appl/h2_server.log

tail -f /home/rocket/rochade/appl/SERV.prot -f /home/rocket/rochade/appl/h2_server.log




