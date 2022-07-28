#!/bin/bash
#
# cr.imson.co
#
# notifications service
# @author Damian Bushong <katana@codebite.net>
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

set +o nounset
if [ -z "$1" ]; then
    echo usage: "$0" \<failing service\>
    exit 1
fi

FAILING_SERVICE=$1
set -o nounset

"$GLOBAL_LOCAL_BIN_PATH/notification.sh" failure "The unit '$FAILING_SERVICE' has failed."
