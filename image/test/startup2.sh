#!/bin/bash
# Author: Guilllermo Avendaño
# Cretion Date: 11/23/2023

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

replace_key(){
    filename=$1
    key_search=$2
    new_value=$3

    while IFS='=' read -r key value || [ -n "$key" ]; do
        if [ "$key" = "$key_search" ]; then
            echo "$key=$new_value"
        else
            echo "$key=$value"
        fi
    done < "$filename" > "$filename.new"

    mv "$filename.new" "$filename"
}

replace_key_web_xml(){

    filename=$1
    key_search=$2
    new_value=$3


    while IFS= read -r linea || [ -n "$linea" ]; do
        if [[ $linea == *"<param-name>$key_search</param-name>"* ]]; then
            echo "$linea"
            IFS= read -r siguiente_linea
            nuevo_valor_linea="<param-value>$new_value</param-value>"
            echo "$nuevo_valor_linea"
        else
            echo "$linea"
        fi
    done < "$filename" > "$filename.new"

    mv "$filename.new" "$filename"

}

replace_camunda_xml(){    
    filename=$1
    key_search=$2
    new_value=$3

    while IFS= read -r linea || [ -n "$linea" ]; do
        if [[ $linea =~ \s+name=\"$key_search\" ]]; then
            # Encuentra y reemplaza el valor en la línea que contiene el atributo name="key"
            linea="${linea/name=\"$key_search\" value=\"[^\"]*\"/name=\"$key_search\" value=\"$new_value\"}"
        fi
        echo "$linea"
    done < "$filename" > "$filename.new"

    mv "$filename.new" "$filename"
 
}

# Copy tomcat configuration files in "/home/rocket/templates" to persistent volume
DI_PERSISTENT_TOMCAT_CONF="/home/rocket/conf"
if [ -z "$(ls -A "$DI_PERSISTENT_TOMCAT_CONF")" ] ; then
    cp -r /home/rocket/templates/* $DI_PERSISTENT_TOMCAT_CONF
fi

declare -A di_folder
di_folder['BgWebServices_classes']="/home/rocket/tomcat/webapps/BgWebServices/WEB-INF/classes"

di_folder['GlobalSearch_classes']="/home/rocket/tomcat/webapps/GlobalSearch/WEB-INF/classes"
di_folder['GlobalSearch_mg_classes']="/home/rocket/tomcat/webapps/GlobalSearch/WEB-INF/classes/mg"
di_folder['GlobalSearch_solr_classes']="/home/rocket/tomcat/webapps/GlobalSearch/WEB-INF/classes/solr"

di_folder['RaaS_classes']="/home/rocket/tomcat/webapps/RaaS/WEB-INF/classes"
di_folder['RaaS_web']="/home/rocket/tomcat/webapps/RaaS/WEB-INF"

di_folder['rochade_classes']="/home/rocket/tomcat/webapps/rochade/WEB-INF/classes"

di_folder['RochadeServices_classes']="/home/rocket/tomcat/webapps/RochadeServices/WEB-INF/classes"

for local_pv in ${!di_folder[@]}; do
    # current directory
    curr_dir=${di_folder[${local_pv}]}

    # if the folder exists 
    if [ -d ${curr_dir} ]; then
        # copy & replace configuration files in Di apps
        cp $DI_PERSISTENT_TOMCAT_CONF/${local_pv}/* ${curr_dir}

    fi # if the folder exists 
done

# This section copy all the configuration files to DI apps, and process ".template" files, and replace parameters 
# Each .template file can contain at least one of the following tags (corresponding to environment variables):

    # <DI_SERVER_HOST>" rochade server hostname, default "di-server"
    # <DI_SERVER_PORT>" rochade server port, default '8888'
    # <DI_SERVER_USER>" rochade server user, default 'ADMIN' 
    # <DI_SERVER_PASS>" rochade server pass, default 'rochade'

    # <DI_POSTGRES_HOST>" (workflow) postgres hostname, default 'di-workflow'
    # <DI_POSTGRES_PORT>" (workflow) postgres port, default: '5432'
    # <DI_POSTGRES_USER>" (workflow) postgres user default 'postgres'
    # <DI_POSTGRES_PASS>" (workflow) postgres password default 'postgres'

    # <DI_SOLR_HOST>" solr hostname, default 'di-solr'
    # <DI_SOLR_PORT>" solr port, default '8983'
    # <DI_WEBAPP_HOST> webhost internal to docker. default di-webapp

rwf_properties="/home/rocket/tomcat/webapps/BgWebServices/WEB-INF/classes/rwf.properties"

replace_key $rwf_properties "host" $DI_SERVER_HOST
replace_key $rwf_properties "user" $DI_SERVER_USER
replace_key $rwf_properties "password" $DI_SERVER_PASS
replace_key $rwf_properties "useTrustedConnection" $DI_SERVER_PASS
replace_key $rwf_properties "bg.url" "http\://$DI_WEBAPP_HOST\:8080/rochade/"

#------------------
# GlobalSearch/WEB-INF/classes
GlobalSearch_startup_properties="home/rocket/tomcat/webapps/GlobalSearch/WEB-INF/classes/startup.properties"
replace_key $GlobalSearch_startup_properties "hostName" $DI_SERVER_HOST
replace_key $GlobalSearch_startup_properties "mg.ui.URL" "http\://$DI_WEBAPP_HOST\:8080/rochade"

#------------------
# GlobalSearch/WEB-INF/classes/mg

GlobalSearch_mg_sorl_properties="home/rocket/tomcat/webapps/GlobalSearch/WEB-INF/classes/mg/sorl.properties"
replace_key $GlobalSearch_mg_sorl_properties "httpSolrServer" "http\://$DI_SOLR_HOST\:8983/solr/"

GlobalSearch_mg_startup_properties="home/rocket/tomcat/webapps/GlobalSearch/WEB-INF/classes/mg/startup.properties"
replace_key $GlobalSearch_mg_startup_properties "hostName" $DI_SERVER_HOST
replace_key $GlobalSearch_mg_startup_properties "mg.ui.URL" "http\://$DI_WEBAPP_HOST\:8080/rochade"

#------------------
# GlobalSearch/WEB-INF/classes/solr
GlobalSearch_solr_sorl_properties="home/rocket/tomcat/webapps/GlobalSearch/WEB-INF/classes/solr/sorl.properties"
replace_key $GlobalSearch_solr_sorl_properties "httpSolrServer" "http\://$DI_SOLR_HOST\:8983/solr/"

#------------------
# RaaS/WEB-INF/classes
RaaS_camunda_cfg_xml="home/rocket/tomcat/webapps/RaaS/WEB-INF/classes/camunda.cfg.xml"
replace_camunda_xml $RaaS_camunda_cfg_xml "jdbcUrl" "jdbc:postgresql://$DI_POSTGRES_HOST:$DI_POSTGRES_PORT/camunda"
replace_camunda_xml $RaaS_camunda_cfg_xml "jdbcDriver" "org.postgresql.Driver"
replace_camunda_xml $RaaS_camunda_cfg_xml "jdbcUsername" "$DI_POSTGRES_USER"
replace_camunda_xml $RaaS_camunda_cfg_xml "jdbcPassword" "$DI_POSTGRES_PASS"

#------------------
# RaaS/WEB-INF/
RaaS_web_xml="home/rocket/tomcat/webapps/RaaS/WEB-INF/web.xml"
replace_key_web_xml $RaaS_camunda_cfg_xml "host" "$DI_SERVER_HOST"

#------------------
# rochade/WEB-INF/classes

rochade_application_is_properties="home/rocket/tomcat/webapps/rochade/WEB-INF/classes/application_is.properties"
replace_key $rochade_application_is_properties "httpSolrServer" "http\://$DI_SOLR_HOST\:8983/solr/"

rochade_camunda_cfg_xml="home/rocket/tomcat/webapps/rochade/WEB-INF/classes/camunda.cfg.xml"
replace_camunda_xml $RaaS_camunda_cfg_xml "jdbcUrl" "jdbc:postgresql://$DI_POSTGRES_HOST:$DI_POSTGRES_PORT/camunda"
replace_camunda_xml $RaaS_camunda_cfg_xml "jdbcDriver" "org.postgresql.Driver"
replace_camunda_xml $RaaS_camunda_cfg_xml "jdbcUsername" "$DI_POSTGRES_USER"
replace_camunda_xml $RaaS_camunda_cfg_xml "jdbcPassword" "$DI_POSTGRES_PASS"

rochade_rdmServices_properties="home/rocket/tomcat/webapps/rochade/WEB-INF/classes/rdmServices.properties"
replace_key $rochade_rdmServices_properties "host" "$DI_SERVER_HOST"

rochade_startup_properties="home/rocket/tomcat/webapps/rochade/WEB-INF/classes/startup.properties"

replace_key $rochade_startup_properties "server.User\ connection=host\"" "\"$DI_SERVER_HOST\" port\=\"8888\""

rochade_wf_properties="home/rocket/tomcat/webapps/rochade/WEB-INF/classes/wf.properties"
replace_key $rochade_wf_properties "bg.webServices" "http\://$DI_WEBAPP_HOST\:8080/BgWebServices"
replace_tag_in_file $rochade_wf_properties "camunda.h2.host" "#camunda.h2.host"
replace_tag_in_file $rochade_wf_properties "camunda.h2.rpcServiceAvailable" "#camunda.h2.rpcServiceAvailable"

cd /home/rocket/tomcat/bin

./catalina.sh run
