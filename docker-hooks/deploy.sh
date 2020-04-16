#!/bin/bash
#
# cr.imson.co
#
# docker container management hook scripts
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DIR="$(dirname "$(readlink -f "$0")")"

DEPLOY_PATH=/srv/docker/hooks
DOCKER_HOOK_PATH=/srv/docker/hooks

FILES=(hook.sh)
DIRS=($DOCKER_HOOK_PATH/pre-start $DOCKER_HOOK_PATH/post-start $DOCKER_HOOK_PATH/pre-stop $DOCKER_HOOK_PATH/post-stop $DOCKER_HOOK_PATH/pre-update $DOCKER_HOOK_PATH/post-update)

if [ "$EUID" -ne 0 ]; then
  echo !! script must be run as root, bailing.
  exit 1
fi

if [ ! -d $DOCKER_HOOK_PATH/ ]; then
  echo :: creating docker hook dir at $DOCKER_HOOK_PATH
  mkdir -p $DOCKER_HOOK_PATH

  chmod 770 $DOCKER_HOOK_PATH
  chown root:docker $DOCKER_HOOK_PATH
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

for DEPLOY_DIR in ${DIRS[@]}; do
  if [ ! -d $DEPLOY_DIR/ ]; then
    echo :: creating dir $DEPLOY_DIR
    mkdir -p $DEPLOY_DIR

    chmod 770 $DEPLOY_DIR
    chown root:docker $DEPLOY_DIR
  fi
done
