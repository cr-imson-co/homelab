#!/bin/bash
#
# cr.imson.co
#
# docker container management scripts
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/docker_config.sh

dockercompose () {
  DOCKER_CONFIG=$DOCKER_CONFIG_PATH docker-compose --log-level ERROR -f "$DOCKER_YML_PATH/$DOCKER_YML_FILENAME" -p "$DOCKER_PROJECT_NAME" "$@"
}
