#!/bin/bash
#
# cr.imson.co
#
# volume-backup service
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/global_config.sh"

echo :: sending success notification...

"$GLOBAL_LOCAL_BIN_PATH/notification.sh" info "homelab backups completed successfully."
