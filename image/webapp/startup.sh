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


# Copy tomcat configuration files in "/home/rocket/templates" to persistent volume
DI_PERSISTENT_TOMCAT_CONF="/home/rocket/conf"
if [ -z "$(ls -A "$DI_PERSISTENT_TOMCAT_CONF")" ] ; then
    cp -r /home/rocket/templates/* $DI_PERSISTENT_TOMCAT_CONF
fi

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

        # File pattern to process
        file_pattern="*.template"

        # Iterate in $curr_dir for all files with $file_pattern
        for template_file in "$curr_dir"/$file_pattern; do

            # Verify if the file exists
            if [ -f "$template_file" ]; then

                config_file=${template_file%.template}
                          
                # it creates a copy of *.xxx.template as *.xxx
                cp $template_file $config_file
                
                echo "Processing: $config_file"   
                
                # replace all the possible parameters 
                replace_tag_in_file $config_file "<DI_SERVER_HOST>" $DI_SERVER_HOST
                replace_tag_in_file $config_file "<DI_SERVER_PORT>" $DI_SERVER_PORT
                replace_tag_in_file $config_file "<DI_SERVER_USER>" $DI_SERVER_USER
                replace_tag_in_file $config_file "<DI_SERVER_PASS>" $DI_SERVER_PASS

                replace_tag_in_file $config_file "<DI_POSTGRES_HOST>" $DI_POSTGRES_HOST
                replace_tag_in_file $config_file "<DI_POSTGRES_PORT>" $DI_POSTGRES_PORT
                replace_tag_in_file $config_file "<DI_POSTGRES_USER>" $DI_POSTGRES_USER
                replace_tag_in_file $config_file "<DI_POSTGRES_PASS>" $DI_POSTGRES_PASS

                replace_tag_in_file $config_file "<DI_SOLR_HOST>" $DI_SOLR_HOST
                replace_tag_in_file $config_file "<DI_SOLR_PORT>" $DI_SOLR_PORT

            else
                echo "No files to process in: $curr_dir/$file_pattern"
            fi
        done
    fi # if the folder exists 
done

cd /home/rocket/tomcat/bin

./catalina.sh run
