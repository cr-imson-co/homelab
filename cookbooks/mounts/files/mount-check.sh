#!/bin/bash
#
# cr.imson.co
#
# mount-check service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env
set -o errexit -o pipefail -o noclobber -o nounset
DIR="$(dirname "$(readlink -f "$0")")"

# todo: make the mounts list dynamic

MOUNTS=(mnt-backup.mount mnt-nextcloud.mount mnt-registry.mount)

for MOUNT_UNIT in ${MOUNTS[@]}; do
  echo :: checking $MOUNT_UNIT

  set +o errexit
  systemctl is-active $MOUNT_UNIT --quiet
  FS_MOUNTED=$?
  set -o errexit

  if [ $FS_MOUNTED -ne 0 ]; then
    echo !! $MOUNT_UNIT is not mounted!
    echo :: attempting to mount...
    # note - if mounting fails, this *should* also fail, but we should
    #   double-check afterward still
    systemctl start $MOUNT_UNIT --quiet

    set +o errexit
    systemctl is-active $MOUNT_UNIT --quiet
    FS_MOUNTED=$?
    set -o errexit

    if [ $FS_MOUNTED -ne 0 ]; then
      echo !! still failed to mount $MOUNT_UNIT, bailing
      exit 1
    fi
  fi
done
