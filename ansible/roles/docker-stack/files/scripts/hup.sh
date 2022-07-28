#!/bin/bash
#
# cr.imson.co
#
# docker container management scripts
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/docker_config.sh"

. "$DOCKER_SCRIPTS_PATH/common.sh"
. "$DOCKER_HOOK_PATH/hook.sh"


set +o nounset
if [ -z "$1" ]; then
    echo usage: "$0" \<target\>
    exit 1
fi

CONTAINER=$1
set -o nounset

echo :: reloading docker container "$CONTAINER"...
dockercompose restart "$CONTAINER"
