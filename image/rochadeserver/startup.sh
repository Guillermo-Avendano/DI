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

# $DI_SERVER_LICENSE_NUMBER, $DI_SERVER_LICENSE_COMPANY are environment variables comming from image's environment variables

RO_APPL="/home/rocket/rochade/appl"

if [ -z "$(ls -A "$RO_APPL")" ]; then
   cp /home/rocket/rochade/appl_template/* /home/rocket/rochade/appl/
fi

SERVER_INI=/home/rocket/rochade/appl/server.ini 

cp $SERVER_INI.template $SERVER_INI

replace_tag_in_file /home/rocket/rochade/appl/server.ini "<DI_SERVER_LICENSE_NUMBER>" $DI_SERVER_LICENSE_NUMBER
replace_tag_in_file /home/rocket/rochade/appl/server.ini "<DI_SERVER_LICENSE_COMPANY>" "$DI_SERVER_LICENSE_COMPANY"

cd /home/rocket/rochade/sbin

./roserver.sh

tail -f /home/rocket/rochade/appl/SERV.prot




