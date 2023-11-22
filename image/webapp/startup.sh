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
RO_SOLR_LOG="/home/rocket/Index_Update_Service/log"

if [ -z "$(ls -A "$RO_SOLR_CONF")" ] && [ -z "$(ls -A "$RO_SOLR_CONF")" ]; then
   cp /home/rocket/Index_Update_Service/conf_template/*.* /home/rocket/Index_Update_Service/conf
fi

TOMCAT_WEBAPPS=/home/rocket/tomcat/webapps/rochade/WEB-INF/classes/

RDM_SERVICES_FILE=$TOMCAT_WEBAPPS/rdmServices.properties
replace_tag_in_file $RDM_SERVICES_FILE "<DI_SERVER_HOST>" $DI_SERVER_HOST
replace_tag_in_file $RDM_SERVICES_FILE "<DI_SERVER_PORT>" $DI_SERVER_PORT
replace_tag_in_file $RDM_SERVICES_FILE "<DI_SERVER_USER>" $DI_SERVER_USER
replace_tag_in_file $RDM_SERVICES_FILE "<DI_SERVER_PASS>" $DI_SERVER_PASS

STARTUP_FILE=$TOMCAT_WEBAPPS/startup.properties
replace_tag_in_file $STARTUP_FILE "<DI_SERVER_HOST>" $DI_SERVER_HOST
replace_tag_in_file $STARTUP_FILE "<DI_SERVER_PORT>" $DI_SERVER_PORT
replace_tag_in_file $STARTUP_FILE "<DI_SERVER_USER>" $DI_SERVER_USER
replace_tag_in_file $STARTUP_FILE "<DI_SERVER_PASS>" $DI_SERVER_PASS

WF_FILE=$TOMCAT_WEBAPPS/wf.properties
replace_tag_in_file $WF_FILE "<DI_SERVER_HOST>" $DI_SERVER_HOST
replace_tag_in_file $WF_FILE "<DI_SERVER_PORT>" $DI_SERVER_PORT
replace_tag_in_file $WF_FILE "<DI_SERVER_USER>" $DI_SERVER_USER
replace_tag_in_file $WF_FILE "<DI_SERVER_PASS>" $DI_SERVER_PASS


APPLICARION_IS_FILE=$TOMCAT_WEBAPPS/application_is.properties
replace_tag_in_file $APPLICARION_IS_FILE "<DI_SOLR_HOST>" $DI_SOLR_HOST
replace_tag_in_file $APPLICARION_IS_FILE "<DI_SOLR_PORT>" $DI_SOLR_PORT

cd /home/rocket/Index_Update_Service/bin

./IndexUpdateService.sh

INDEX_LOG_FILE="/home/rocket/Index_Update_Service/log/indexing.log"
if test -f "$INDEX_LOG_FILE"; then
    tail -f $INDEX_LOG_FILE
    
fi





