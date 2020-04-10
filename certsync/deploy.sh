#!/bin/bash
#
# cr.imson.co
#
# certsync service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DIR="$(dirname "$(readlink -f "$0")")"

DEPLOY_PATH=/etc/systemd/system
DOCKER_HOOK_PATH=/srv/docker/hooks

FILES=(certfetch.sh certsync.sh)
UNITS=(certsync.service certsync.timer)
SYSTEMD_UNIT_CHECKS=(certsync.timer)

if [ "$EUID" -ne 0 ]; then
  echo !! script must be run as root, bailing.
  exit 1
fi

for FILE in ${FILES[@]}; do
  echo :: deploying $DIR/bin/$FILE
  cp $DIR/bin/$FILE /usr/local/bin/$FILE

  chmod 740 /usr/local/bin/$FILE
  chown root:staff /usr/local/bin/$FILE
done

# certfetch is a little special...
chmod 750 /usr/local/bin/certfetch.sh
chown root:certsync /usr/local/bin/certfetch.sh

for DEPLOY_UNIT in ${UNITS[@]}; do
  echo :: deploying $DIR/$DEPLOY_UNIT
  cp $DIR/systemd/$DEPLOY_UNIT $DEPLOY_PATH/$DEPLOY_UNIT

  chmod 644 $DEPLOY_PATH/$DEPLOY_UNIT
  chown root:root $DEPLOY_PATH/$DEPLOY_UNIT
done

echo :: reloading systemd unit files...
systemctl daemon-reload > /dev/null 2>&1

for SYSTEMD_UNIT in ${SYSTEMD_UNIT_CHECKS[@]}; do
  if ! systemctl list-unit-files --state=enabled | grep $SYSTEMD_UNIT > /dev/null 2>&1; then
    echo !! the $SYSTEMD_UNIT systemd unit is not enabled
  fi
done
