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

for DEPLOY_FILE in ${FILES[@]}; do
  echo :: deploying $DIR/$DEPLOY_FILE
  cp $DIR/$DEPLOY_FILE $DEPLOY_PATH/$DEPLOY_FILE

  if [ ${DEPLOY_FILE: -3} == '.sh' ]; then
    chmod 770 $DEPLOY_PATH/$DEPLOY_FILE
  else
    chmod 660 $DEPLOY_PATH/$DEPLOY_FILE
  fi

  chown root:docker $DEPLOY_PATH/$DEPLOY_FILE
done

for DEPLOY_HOOK in ${HOOKS[@]}; do
  cp $DIR/docker-hooks/$DEPLOY_HOOK $DOCKER_HOOK_PATH/$DEPLOY_HOOK
  chmod 770 $DOCKER_HOOK_PATH/$DEPLOY_HOOK
  chown root:docker $DOCKER_HOOK_PATH/$DEPLOY_HOOK
done
