#!/bin/bash
#
# cr.imson.co
#
# docker container management scripts
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/docker_config.sh"

"$DOCKER_SCRIPTS_PATH/stop.sh"
"$DOCKER_SCRIPTS_PATH/start.sh"
