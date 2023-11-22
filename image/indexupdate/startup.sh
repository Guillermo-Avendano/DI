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

RO_SOLR_CONF="/home/rocket/Index_Update_Service/conf"

if [ -z "$(ls -A "$RO_SOLR_CONF")" ] ; then
   cp /home/rocket/Index_Update_Service/conf_template/*.* /home/rocket/Index_Update_Service/conf
fi

INDEX_UPDATER_CONFIG_FILE=/home/rocket/Index_Update_Service/conf/indexUpdater.properties

replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "#RO_SOLR_HOST#" $RO_SOLR_HOST
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "#RO_SOLR_PORT#" $RO_SOLR_PORT
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "#RO_HOST#"      $RO_HOST
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "#RO_PORT#"      $RO_PORT
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "#RO_USER#"      $RO_USER
replace_tag_in_file $INDEX_UPDATER_CONFIG_FILE "#RO_PASS#"      $RO_PASS

cd /home/rocket/Index_Update_Service/bin

./IndexUpdateService.sh

tail -f /home/rocket/Index_Update_Service/logs/indexing.log




