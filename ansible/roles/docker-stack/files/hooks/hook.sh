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
. /srv/homelab/docker_config.sh

hook () {
  HOOK_NAME=$1
  shift 1

  if [[ -e $DOCKER_HOOK_PATH/$HOOK_NAME/ ]]; then
    for HOOK in "$DOCKER_HOOK_PATH/$HOOK_NAME"/*; do
      if [[ -x "$HOOK" ]]; then
        echo :: running hook "$HOOK_NAME"/"$(basename "$HOOK")"
        "$HOOK" "$@" || exit 1
      fi
    done
  fi
}
