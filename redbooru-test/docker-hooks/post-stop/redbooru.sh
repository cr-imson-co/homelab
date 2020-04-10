#!/bin/bash
#
# redbooru
#
# docker container management scripts
# @author Damian Bushong <katana@redbooru.io>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DOCKER_PROJECT_NAME=redbooru
YML_PATH=/srv/redbooru

echo :: verifying that redbooru integration environment containers are no longer running
if [[ ! -z $(docker-compose --log-level ERROR -f $YML_PATH/docker-compose.yml -p $DOCKER_PROJECT_NAME ps -q) ]]; then
  echo :: containers are still running even after down request, bailing
  sleep 3
  exit 1
fi
