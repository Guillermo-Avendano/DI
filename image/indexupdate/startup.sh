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

RO_SOLR_CONF="/home/rocket/Index_Update_Service/conf"

if [ -z "$(ls -A "$RO_SOLR_CONF")" ] ; then
   cp /home/rocket/Index_Update_Service/conf_template/*.* /home/rocket/Index_Update_Service/conf
fi

INDEX_UPDATER_CONFIG_FILE=/home/rocket/Index_Update_Service/conf/indexUpdater.properties
cp $INDEX_UPDATER_CONFIG_FILE.template $INDEX_UPDATER_CONFIG_FILE

replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SOLR_HOST>"   $DI_SOLR_HOST
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SOLR_PORT>"   $DI_SOLR_PORT
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SERVER_HOST>" $DI_SERVER_HOST
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SERVER_PORT>" $DI_SERVER_PORT
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SERVER_USER>" $DI_SERVER_USER
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "<DI_SERVER_PASS>" $DI_SERVER_PASS

cd /home/rocket/Index_Update_Service/bin

./IndexUpdateService.sh

tail -f /home/rocket/Index_Update_Service/logs/indexing.log




