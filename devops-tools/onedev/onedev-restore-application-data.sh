#!/bin/bash
set -e

ONEDEV_CONTAINER=$(podman ps -aqf "name=onedev-main")
ONEDEV_BACKUPS_CONTAINER=$(podman ps -aqf "name=onedev-psql-backup")

echo "--> All available application data backups:"

for entry in $(podman container exec -it $ONEDEV_BACKUPS_CONTAINER sh -c "ls /srv/onedev-application-data/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore application data and press [ENTER]
--> Example: onedev-application-data-backup-YYYY-MM-DD_hh-mm.tar.gz"
echo -n "--> "

read SELECTED_APPLICATION_BACKUP

echo "--> $SELECTED_APPLICATION_BACKUP was selected"

echo "--> Stopping service..."
podman stop $ONEDEV_CONTAINER

echo "--> Restoring application data..."
podman exec -it $ONEDEV_BACKUPS_CONTAINER sh -c "rm -rf /opt/onedev/* && tar -zxpf /srv/onedev-application-data/backups/$SELECTED_APPLICATION_BACKUP -C /"
echo "--> Application data recovery completed..."

echo "--> Starting service..."
podman start $ONEDEV_CONTAINER
