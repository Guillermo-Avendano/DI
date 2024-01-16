WEBAPPS_HOME=/home/rocket/di/image/webapp/webapps
find $WEBAPPS_HOME/ -type f -name "*.yaml" -exec grep -l "8888" {} + | xargs -I {} rsync -R {} .
find $WEBAPPS_HOME/ -type f -name "*.properties" -exec grep -l "8888" {} + 
find $WEBAPPS_HOME/ -type f -name "*.xml" -exec grep -l "8888" {} + 

find $WEBAPPS_HOME/ -type f -name "*.yaml" -exec grep -l "8983" {} + 
find $WEBAPPS_HOME/ -type f -name "*.properties" -exec grep -l "8983" {} + 
find $WEBAPPS_HOME/ -type f -name "*.xml" -exec grep -l "8938" {} + 

find $WEBAPPS_HOME/ -type f -name "*.yaml" -exec grep -l "di_webapp" {} + 
find $WEBAPPS_HOME/ -type f -name "*.properties" -exec grep -l "di_webapp" {} + 
find $WEBAPPS_HOME/ -type f -name "*.xml" -exec grep -l "di_webapp" {} + 
