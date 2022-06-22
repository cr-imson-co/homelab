#!/bin/bash
#
# cr.imson.co
#
# volume-backup service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

set +o errexit
systemctl is-active mnt-backup.mount --quiet
BACKUP_FS_MOUNTED=$?
set -o errexit

if [ $BACKUP_FS_MOUNTED -ne 0 ]; then
  echo !! backup network filesystem is not mounted!
  echo :: attempting to mount...
  # note - if mounting fails, this *should* also fail, but we should
  #   double-check afterward still
  systemctl start mnt-backup.mount --quiet

  set +o errexit
  systemctl is-active mnt-backup.mount --quiet
  BACKUP_FS_MOUNTED=$?
  set -o errexit

  if [ $BACKUP_FS_MOUNTED -ne 0 ]; then
    echo !! still failed to mount backup network filesystem, bailing
    exit 1
  fi
fi
