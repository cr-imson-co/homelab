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
HOOK_PATH=/srv/docker/hooks

. $DIR/common.sh
. $HOOK_PATH/hook.sh

hook pre-start-redbooru
echo :: starting redbooru docker containers...
dockercompose up -d
hook post-start-redbooru
