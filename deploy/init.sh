#!/bin/bash

source .env

docker-compose -f ./docker-compose.db.yaml up -d --remove-orphans

DOTS="..."
# Verificar si hay contenedores ejecutándose con la imagen especificada
while docker ps --format '{{.Image}}' | grep -q $DI_DB1_IMAGE; do
    echo "Processing $DI_DB1_IMAGE image $DOTS"
    sleep 2
    DOTS="$DOTS..."
done

echo "$DI_DB1_IMAGE processed"

DOTS="..."
# Verificar si hay contenedores ejecutándose con la imagen especificada
while docker ps --format '{{.Image}}' | grep -q $DI_DB2_IMAGE; do
    echo "Processing $DI_DB2_IMAGE image $DOTS"
    sleep 2
    DOTS="$DOTS..."
done

echo "$DI_DB2_IMAGE processed"

sudo chmod -R 777 di_server_datbas/