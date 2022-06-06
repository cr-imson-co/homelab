#!/bin/bash
#
# cr.imson.co
#
# notifications service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env
set -o errexit -o pipefail -o noclobber -o nounset

if [ "$EUID" -ne 0 ]; then
  echo !! script must be run as root, bailing.
  exit 1
fi

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/global_config.sh"
. "$HOMELAB_CONFIG_PATH/secrets_config.sh"

set +o nounset
if [ -z "$2" ]; then
    echo usage: "$0" \<state\> \<message\>
    exit 1
fi

NOTIFICATION_TYPE=$1
shift 1
MESSAGE=$*
set -o nounset

"$GLOBAL_LOCAL_BIN_PATH/apprise" \
  --title "homelab $NOTIFICATION_TYPE event" \
  --body "$MESSAGE" \
  --notification-type "$NOTIFICATION_TYPE" \
  "$SECRET_APPRISE_NOTIFICATION_URL/?avatar=No&format=markdown&image=No"
