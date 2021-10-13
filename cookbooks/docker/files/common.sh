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
. /srv/homelab/docker_config.sh

dockercompose () {
  docker-compose --log-level ERROR -f "$DOCKER_YML_PATH/$DOCKER_YML_FILENAME" -p "$DOCKER_PROJECT_NAME" "$@"
}
