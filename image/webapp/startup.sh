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

mkdir /home/rocket/graphviz
cd /home/rocket/graphviz

zcat /home/rocket/graphviz-2.38.0-linux64.tar.Z| tar -xvf -

echo CATALINA_OPTS=\”-Xms1024 -Xmx8192\” > /home/rocket/tomcat/bin/setenv.sh

chmod u+x home/rocket/tomcat/bin/*.sh

DI_TOMCAT_CONF="/home/rocket/conf"
RO_SOLR_LOG="/home/rocket/Index_Update_Service/log"

if [ -z "$(ls -A "$DI_TOMCAT_CONF")" ] ; then
    cp -r /home/rocket/templates/ /home/rocket/conf/
fi

cp /home/rocket/conf/bdi_classes/*.* /home/rocket/tomcat/webapps/bdi/WEB-INF/classes/
cp /home/rocket/conf/rochade_classes/*.* /home/rocket/tomcat/webapps/rochade/WEB-INF/classes/
cp /home/rocket/conf/GlobalSearch_classes/*.* /home/rocket/tomcat/webapps/GlobalSearch/WEB-INF/classes/
cp /home/rocket/conf/BGWebServices_classes/*.* /home/rocket/tomcat/webapps/BgWebServices/WEB-INF/classes/
cp /home/rocket/conf/RochadeServices_classes/*.* /home/rocket/tomcat/webapps/RochadeServices/WEB-INF/classes/


rochade_WEB_INF_classes=/home/rocket/tomcat/webapps/rochade/WEB-INF/classes/

RDM_SERVICES_FILE=$rochade_WEB_INF_classes/rdmServices.properties
replace_tag_in_file $RDM_SERVICES_FILE "<DI_SERVER_HOST>" $DI_SERVER_HOST
replace_tag_in_file $RDM_SERVICES_FILE "<DI_SERVER_PORT>" $DI_SERVER_PORT
replace_tag_in_file $RDM_SERVICES_FILE "<DI_SERVER_USER>" $DI_SERVER_USER
replace_tag_in_file $RDM_SERVICES_FILE "<DI_SERVER_PASS>" $DI_SERVER_PASS

STARTUP_FILE=$rochade_WEB_INF_classes/startup.properties
replace_tag_in_file $STARTUP_FILE "<DI_SERVER_HOST>" $DI_SERVER_HOST
replace_tag_in_file $STARTUP_FILE "<DI_SERVER_PORT>" $DI_SERVER_PORT
replace_tag_in_file $STARTUP_FILE "<DI_SERVER_USER>" $DI_SERVER_USER
replace_tag_in_file $STARTUP_FILE "<DI_SERVER_PASS>" $DI_SERVER_PASS

WF_FILE=$rochade_WEB_INF_classes/wf.properties
replace_tag_in_file $WF_FILE "<DI_SERVER_HOST>" $DI_SERVER_HOST
replace_tag_in_file $WF_FILE "<DI_SERVER_PORT>" $DI_SERVER_PORT
replace_tag_in_file $WF_FILE "<DI_SERVER_USER>" $DI_SERVER_USER
replace_tag_in_file $WF_FILE "<DI_SERVER_PASS>" $DI_SERVER_PASS

CAMUNDA_CFG_FILE=$rochade_WEB_INF_classes/camunda.cfg.xml
replace_tag_in_file $CAMUNDA_CFG_FILE "<DI_POSTGRES_HOST>" $DI_POSTGRES_HOST
replace_tag_in_file $CAMUNDA_CFG_FILE "<DI_POSTGRES_PORT>" $DI_POSTGRES_PORT
replace_tag_in_file $CAMUNDA_CFG_FILE "<DI_POSTGRES_USER>" $DI_POSTGRES_USER
replace_tag_in_file $CAMUNDA_CFG_FILE "<DI_POSTGRES_PASS>" $DI_POSTGRES_PASS

cp $CAMUNDA_CFG_FILE /home/rocket/tomcat/webapps/RaaS/WEB-INF/classes/camunda.cfg.xml

APPLICARION_IS_FILE=$TOMCAT_WEBAPPS/application_is.properties
replace_tag_in_file $APPLICARION_IS_FILE "<DI_SOLR_HOST>" $DI_SOLR_HOST
replace_tag_in_file $APPLICARION_IS_FILE "<DI_SOLR_PORT>" $DI_SOLR_PORT

cd /home/rocket/tomcat/bin

./startup.sh

tail -f /home/rocket/tomcat/logs/catalina.out






