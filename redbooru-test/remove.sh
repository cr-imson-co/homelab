#!/bin/bash
#
# redbooru integration environment
#
# docker container management scripts
# @author Damian Bushong <katana@redbooru.io>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DIR="$(dirname "$(readlink -f "$0")")"

DEPLOY_PATH=/srv/redbooru
DOCKER_HOOK_PATH=/srv/docker/hooks

FILES=(docker-compose.yml common.sh restart.sh start.sh stop.sh update.sh)
HOOKS=(post-start/redbooru.sh post-stop/redbooru.sh pre-stop/redbooru.sh)

if [ "$EUID" -ne 0 ]; then
  echo !! script must be run as root, bailing.
  exit 1
fi

echo :: this script will remove the redbooru environment
read -p "   proceed? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo :: ensuring redbooru environment is stopped
  $DEPLOY_PATH/stop.sh

  for DEPLOY_FILE in ${FILES[@]}; do
    echo :: removing $DEPLOY_PATH/$DEPLOY_FILE
    rm -f $DEPLOY_PATH/$DEPLOY_FILE
  done

  for DEPLOY_HOOK in ${HOOKS[@]}; do
    echo :: removing $DOCKER_HOOK_PATH/$DEPLOY_HOOK
    rm -f $DOCKER_HOOK_PATH/$DEPLOY_HOOK
  done

  echo :: removal completed
else
    echo !! aborting
fi
