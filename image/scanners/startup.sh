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

RO_APPL="/home/rocket/rochade/appl"

if [ -z "$(ls -A "$RO_APPL")" ]; then
   cp /home/rocket/rochade/appl_template/* /home/rocket/rochade/appl/
fi

cd /home/rocket/tomcat/bin

./catalina.sh run




