#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE workflow LOGIN PASSWORD 'postgres';
    GRANT  workflow TO postgres;
    CREATE DATABASE camunda OWNER workflow ENCODING 'UTF8' TEMPLATE template0 LC_COLLATE 'C' LC_CTYPE 'C' CONNECTION LIMIT -1; 
EOSQL
