#!/bin/bash
#
# valheim server
#
# docker container management scripts
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/docker_config.sh"
. "$HOMELAB_CONFIG_PATH/valheim_config.sh"

. "$VALHEIM_SCRIPTS_PATH/common.sh"
. "$DOCKER_HOOK_PATH/hook.sh"

hook pre-update-valheim
echo :: pulling valheim docker image updates...
dockercompose pull
hook post-update-valheim
