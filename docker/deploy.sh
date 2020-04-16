#!/bin/bash
#
# cr.imson.co
#
# docker container management scripts
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

DIR="$(dirname "$(readlink -f "$0")")"
DEPLOY_PATH=/srv/docker
REGISTRY_CONFIG_PATH=/srv/registry

FILES=(docker-compose.yml common.sh restart.sh start.sh stop.sh update.sh)
FILE_EXIST_CHECKS=($DEPLOY_PATH/mysql_root_password $DEPLOY_PATH/mysql_password $REGISTRY_CONFIG_PATH/config.yml)

if [ "$EUID" -ne 0 ]; then
  echo !! script must be run as root, bailing.
  exit 1
fi

for FILE in ${FILES[@]}; do
  echo :: deploying $DIR/$FILE
  cp $DIR/$FILE $DEPLOY_PATH/$FILE

  if [ ${FILE: -3} == '.sh' ]; then
    chmod 770 $DEPLOY_PATH/$FILE
  else
    chmod 660 $DEPLOY_PATH/$FILE
  fi

  chown root:docker $DEPLOY_PATH/$FILE
done

for FILE_EXIST_CHECK in ${FILE_EXIST_CHECKS[@]}; do
  if [ ! -f $FILE_EXIST_CHECK ]; then
    echo !! the file $FILE_EXIST_CHECK needs to be created per documentation
  fi
done
