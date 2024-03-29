#!/bin/bash
#
# cr.imson.co
#
# mount-check service
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/mount_config.sh"

for MOUNT_UNIT in "${MOUNT_CHECK_IF_ACTIVE_MOUNTS[@]}"; do
  echo :: checking "$MOUNT_UNIT"

  set +o errexit
  systemctl is-active "$MOUNT_UNIT" --quiet
  FS_MOUNTED=$?
  set -o errexit

  if [ $FS_MOUNTED -ne 0 ]; then
    echo !! "$MOUNT_UNIT" is not mounted!
    echo :: attempting to mount...
    # note - if mounting fails, this *should* also fail, but we should
    #   double-check afterward still
    systemctl start "$MOUNT_UNIT" --quiet

    set +o errexit
    systemctl is-active "$MOUNT_UNIT" --quiet
    FS_MOUNTED=$?
    set -o errexit

    if [ $FS_MOUNTED -ne 0 ]; then
      echo !! still failed to mount "$MOUNT_UNIT", bailing
      exit 1
    fi
  fi
done
