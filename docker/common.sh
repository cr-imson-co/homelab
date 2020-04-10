#!/bin/bash
#
# cr.imson.co
#
# docker container management scripts
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DOCKER_PROJECT_NAME=docker
YML_PATH=/srv/docker

dockercompose () {
  docker-compose --log-level ERROR -f $YML_PATH/docker-compose.yml -p $DOCKER_PROJECT_NAME $@
}
