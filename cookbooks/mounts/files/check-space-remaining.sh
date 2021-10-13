#!/bin/bash
#
# cr.imson.co
#
# mount-check service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/global_config.sh"

FILESYSTEMS=(/ /home /var /mnt/backup /mnt/nextcloud)
CRITICAL_THRESHOLD="90"
WARNING_THRESHOLD="75"

for FILESYSTEM in "${FILESYSTEMS[@]}"; do
  echo :: checking "$FILESYSTEM" space available

  FS_INFO=$(df -Ph "$FILESYSTEM" | tail -1)

  # shellcheck disable=SC2034
  FS_TOTAL=$(echo "$FS_INFO" | awk '{ print $2 }')
  FS_USED=$(echo "$FS_INFO" | awk '{ print $3 }')
  FS_AVAIL=$(echo "$FS_INFO" | awk '{ print $4 }')
  FS_UTIL=$(echo "$FS_INFO" | awk '{ print substr($5, 0, length($5)) }')

  if [[ "$FS_UTIL" -gt $CRITICAL_THRESHOLD ]]; then
    "$GLOBAL_LOCAL_BIN_PATH/notification.sh" failure "\`$FILESYSTEM\` mount at critical mark for disk space ($FS_USED/$FS_AVAIL; $FS_UTIL% used)."
  elif [[ "$FS_UTIL" -gt $WARNING_THRESHOLD ]]; then
    "$GLOBAL_LOCAL_BIN_PATH/notification.sh" warning "\`$FILESYSTEM\` mount at high-water mark for disk space ($FS_USED/$FS_AVAIL; $FS_UTIL% used)."
  fi
done
