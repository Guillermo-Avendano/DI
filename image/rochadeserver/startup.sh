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
# $DI_SERVER_LICENSE_NUMBER, $DI_SERVER_LICENSE_COMPANY are environment variables comming from image's environment variables

SERVER_INI=/home/rocket/rochade/appl/server.ini 

RO_APPL="/home/rocket/rochade/appl"

if [ -z "$(ls -A "$RO_APPL")" ]; then
    cp /home/rocket/rochade/appl_template/* /home/rocket/rochade/appl/
    # Verify if the copy from the image to the volume has finished with md5
    d1=false
    d2=false
    DB_PATH=/home/rocket/rochade/datbas/
    for i in {1..3}; do
        md5=$(md5sum $DB_PATH/d1.rodb | awk '{print $1}')
        expected=$(cat $DB_PATH/d1.md5 | awk '{print $1}')
        if [ "$md5" == "$expected" ]; then
            echo "$DB_PATH/d1.rodb md5sum verified, attempt $i"
            d1=true
            break
        else
            echo "$DB_PATH/d1.rodb md5sum not verified, attempt $i"
        fi
    done

    # Verificar d2.rodb
    for i in {1..3}; do
        md5=$(md5sum $DB_PATH/d2.rodb | awk '{print $1}')
        expected=$(cat $DB_PATH/d2.md5 | awk '{print $1}')
        if [ "$md5" == "$expected" ]; then
            echo "$DB_PATH/d2.rodb md5sum verified, attempt $i"
            d2=true
            break
        else
            echo "$DB_PATH/d2.rodb md5sum not verified, attempt $i"
        fi
    done
else
    d1=true
    d2=true
fi

replace_key $SERVER_INI "LICENSE" $DI_SERVER_LICENSE_NUMBER
replace_key $SERVER_INI "COMPANY" "$DI_SERVER_LICENSE_COMPANY"


if [ "$d1" = true ] && [ "$d2" = true ]; then
    cd /home/rocket/rochade/sbin
    ./roserver.sh

    rochade_log="/home/rocket/rochade/appl/SERV.prot"

    # Verificar si el archivo existe
    while [ ! -e "$rochade_log" ]; do
        echo "Starting Rochade server..."
        sleep 1  # Esperar 1 segundo antes de volver a verificar
    done

    tail -f $rochade_log
else
    echo "The database files are not valid."
fi




