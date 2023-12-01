#!/bin/bash
set -e
source ./.env

GRAFANA_CONTAINER=$(docker ps -aqf "name=grafana")
GRAFANA_BACKUPS_CONTAINER=$(docker ps -aqf "name=psql-backup")

echo "--> All available database backups:"

for entry in $(docker container exec -it $GRAFANA_BACKUPS_CONTAINER sh -c "ls /srv/grafana-postgres/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore database and press [ENTER]
--> Example: grafana-postgres-backup-YYYY-MM-DD_hh-mm.gz"
echo -n "--> "

read SELECTED_DATABASE_BACKUP

echo "--> $SELECTED_DATABASE_BACKUP was selected"

echo "--> Stopping service..."
docker stop $GRAFANA_CONTAINER

echo "--> Restoring database..."
docker exec -it $GRAFANA_BACKUPS_CONTAINER sh -c 'PGPASSWORD="$(echo ${POSTGRESQL_PASSWORD})" dropdb -h postgres-grafana.io -p 5432 ${POSTGRESQL_DATABASE} -U ${POSTGRESQL_USERNAME} \
&& PGPASSWORD="$(echo ${POSTGRESQL_DATABASE})" createdb -h postgres-grafana.io -p 5432 ${POSTGRESQL_DATABASE} -U ${POSTGRESQL_USERNAME} \
&& PGPASSWORD="$(echo ${POSTGRESQL_DATABASE})" gunzip -c /srv/grafana-postgres/backups/'$SELECTED_DATABASE_BACKUP' | PGPASSWORD=$(echo $GRAFANA_DB_PASS) psql -h postgres-grafana.io -p 5432 ${POSTGRESQL_DATABASE} -U ${POSTGRESQL_USERNAME}'
echo "--> Database recovery completed..."

echo "--> Starting service..."
docker start $GRAFANA_CONTAINER
