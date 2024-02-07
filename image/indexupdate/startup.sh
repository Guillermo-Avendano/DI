#!/bin/bash
#!/bin/bash
# Author: Guilllermo Avendaño
# Cretion Date: 11/21/2023

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

# Wait for Rochade Server
wait_for_service() {
    local service=$1
    local port=$2
    local timeout=$3
    local interval=$4

    echo "Waiting for $service be available..."

    timeout $timeout bash -c "\
        while ! nc -zv $service $port; do \
            echo \"Service $service not available yet. Waiting...\"; \
            sleep $interval; \
        done"

    if [ $? -eq 0 ]; then
        echo "Service $service available in $port."
    else
        echo "Timeout waiting for the service $service port $port."
        exit 1
    fi
}

# Wait for di-server 8888 be available
wait_for_service "$DI_SERVER_HOST" "8888" "10" "5"

RO_SOLR_CONF="/home/rocket/Index_Update_Service/conf"

if [ -z "$(ls -A "$RO_SOLR_CONF")" ] ; then
   cp /home/rocket/Index_Update_Service/conf_template/* /home/rocket/Index_Update_Service/conf/
fi

INDEX_UPDATER_CONFIG_FILE=/home/rocket/Index_Update_Service/conf/indexUpdater.properties
cp $INDEX_UPDATER_CONFIG_FILE.template $INDEX_UPDATER_CONFIG_FILE

replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SOLR_HOST>"   $DI_SOLR_HOST
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SOLR_PORT>"   $DI_SOLR_PORT
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SOLR_TRUSTED>"  $DI_SOLR_TRUSTED
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SERVER_HOST>" $DI_SERVER_HOST
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SERVER_PORT>" $DI_SERVER_PORT
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SERVER_USER>" $DI_SERVER_USER
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SERVER_PASS>" $DI_SERVER_PASS


LOG4J_CONFIG_FILE=/home/rocket/Index_Update_Service/conf/log4j2.xml
cp $LOG4J_CONFIG_FILE.template $LOG4J_CONFIG_FILE
replace_tag_in_file $LOG4J_CONFIG_FILE "<DI_SOLR_ERROR_LEVEL>" $DI_SOLR_ERROR_LEVEL

cd /home/rocket/Index_Update_Service/bin

./IndexUpdateService.sh
