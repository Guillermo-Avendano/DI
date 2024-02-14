#!/bin/bash


docker-compose -f ./docker-compose.db.yaml up -d --remove-orphans

CONTAINER_NAME="db1_empty_init"

# Verificar si el contenedor está en ejecución
while [[ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" == "true" ]]; do
    echo "Waiting $CONTAINER_NAME finish with inicialization..."
    sleep 1
done

echo "$CONTAINER_NAME has finished."

CONTAINER_NAME="db2_empty_init"

# Verificar si el contenedor está en ejecución
while [[ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" == "true" ]]; do
    echo "Waiting $CONTAINER_NAME finish with inicialization..."
    sleep 1
done

echo "$CONTAINER_NAME has finished."

