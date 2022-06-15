#!/bin/ash

# container-backup.fnc
#
# Calls the gitea backup function and unpacks the data
# in the /var/backup folder and delete the zip file.

container_backup() {
 /usr/bin/gitea --config /opt/gitea/app.ini --work-path /opt/gitea --custom-path /opt/gitea/custom dump
 /usr/bin/unzip gitea-dump-*.zip
 /bin/rm gitea-dump-*.zip
}
