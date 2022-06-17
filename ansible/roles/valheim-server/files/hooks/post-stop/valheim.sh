#!/bin/bash
#
# valheim
#
# docker container management scripts
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DOCKER_PROJECT_NAME=valheim
YML_PATH=/srv/valheim

echo :: verifying that valheim containers are no longer running
if [[ -n $(docker-compose --log-level ERROR -f $YML_PATH/docker-compose.yml -p $DOCKER_PROJECT_NAME ps -q) ]]; then
  echo :: containers are still running even after down request, bailing
  sleep 3
  exit 1
fi
