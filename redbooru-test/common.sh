#!/bin/bash
#
# redbooru integration environment
#
# docker container management scripts
# @author Damian Bushong <katana@redbooru.io>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DOCKER_PROJECT_NAME=redbooru
YML_PATH=/srv/redbooru

dockercompose () {
  docker-compose --log-level ERROR -f $YML_PATH/docker-compose.yml -p $DOCKER_PROJECT_NAME $@
}
