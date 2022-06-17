#!/bin/bash
#
# valheim server
#
# docker container management scripts
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/docker_config.sh"
. "$HOMELAB_CONFIG_PATH/valheim_config.sh"

dockercompose () {
  DOCKER_CONFIG=$DOCKER_CONFIG_PATH docker-compose --log-level ERROR -f "$VALHEIM_YML_PATH/$VALHEIM_YML_FILENAME" -p "$VALHEIM_PROJECT_NAME" "$@"
}
