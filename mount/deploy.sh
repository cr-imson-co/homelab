#!/bin/bash
#
# cr.imson.co
#
# mount-check service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DIR="$(dirname "$(readlink -f "$0")")"

BIN_DEPLOY_PATH=/usr/local/bin
SYSTEMD_DEPLOY_PATH=/etc/systemd/system

FILES=(mount-check.sh)
UNITS=(mnt-backup.mount mnt-nexus.mount mount-check.service mount-check.timer)
SYSTEMD_UNIT_CHECKS=(mnt-backup.mount mnt-nexus.mount mount-check.timer)
MANUALLY_CREATED_FILES=(/etc/samba/credentials/backup /etc/samba/credentials/nexus)

if [ "$EUID" -ne 0 ]; then
  echo !! script must be run as root, bailing.
  exit 1
fi

for FILE in ${FILES[@]}; do
  echo :: deploying $DIR/bin/$FILE
  cp $DIR/bin/$FILE $BIN_DEPLOY_PATH/$FILE

  chmod 744 $BIN_DEPLOY_PATH/$FILE
  chown root:staff $BIN_DEPLOY_PATH/$FILE
done

for DEPLOY_UNIT in ${UNITS[@]}; do
  echo :: deploying $DIR/$DEPLOY_UNIT
  cp $DIR/systemd/$DEPLOY_UNIT $SYSTEMD_DEPLOY_PATH/$DEPLOY_UNIT

  chmod 644 $SYSTEMD_DEPLOY_PATH/$DEPLOY_UNIT
  chown root:root $SYSTEMD_DEPLOY_PATH/$DEPLOY_UNIT
done

echo :: reloading systemd unit files...
systemctl daemon-reload > /dev/null 2>&1

for MANUALLY_CREATED_FILE in ${MANUALLY_CREATED_FILES[@]}; do
  if [ ! -f $MANUALLY_CREATED_FILE ]; then
    echo !! the file $MANUALLY_CREATED_FILE must be manually created and populated!
  fi
done

for SYSTEMD_UNIT in ${SYSTEMD_UNIT_CHECKS[@]}; do
  if ! systemctl list-unit-files --state=enabled | grep $SYSTEMD_UNIT > /dev/null 2>&1; then
    echo !! the $SYSTEMD_UNIT systemd unit is not enabled
  fi
done
