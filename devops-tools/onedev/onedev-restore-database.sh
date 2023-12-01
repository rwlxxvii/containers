#!/bin/bash
set -e

ONEDEV_CONTAINER=$(podman ps -aqf "name=onedev")
ONEDEV_BACKUPS_CONTAINER=$(podman ps -aqf "name=onedev-psql-backup")

echo "--> All available database backups:"

for entry in $(podman container exec -it $ONEDEV_BACKUPS_CONTAINER sh -c "ls /srv/onedev-postgres/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore database and press [ENTER]
--> Example: onedev-postgres-backup-YYYY-MM-DD_hh-mm.gz"
echo -n "--> "

read SELECTED_DATABASE_BACKUP

echo "--> $SELECTED_DATABASE_BACKUP was selected"

echo "--> Stopping service..."
podman stop $ONEDEV_CONTAINER

echo "--> Restoring database..."
podman exec -it $ONEDEV_BACKUPS_CONTAINER sh -c 'PGPASSWORD="$(echo $POSTGRES_PASS)" dropdb -h postgres-onedev.dev.io -p 5432 onedev -U "${POSTGRES_USER}" \
&& PGPASSWORD="$(echo $POSTGRES_PASS)" createdb -h postgres-onedev.dev.io -p 5432 onedev -U "${POSTGRES_USER}" \
&& PGPASSWORD="$(echo $POSTGRES_PASS)" gunzip -c /srv/onedev-postgres/backups/'$SELECTED_DATABASE_BACKUP' | PGPASSWORD=$(echo $POSTGRES_PASS) psql -h postgres-onedev.dev.io -p 5432 onedev -U "${POSTGRES_USER}"'
echo "--> Database recovery completed..."

echo "--> Starting service..."
podman start $ONEDEV_CONTAINER
