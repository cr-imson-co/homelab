#!/bin/bash
#
# cr.imson.co
#
# volume-backup service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/backup_config.sh"

if [[ "$BACKUP_BACKUP_REPO" == "true" ]]; then
    echo :: backing up homelab repo...

    TEMP_REPO_PATH=$(mktemp -d -p "$BACKUP_STAGING_PATH/")

    pushd "$TEMP_REPO_PATH/" > /dev/null

    git clone --depth 1 "$BACKUP_GIT_REPO" .

    HOMELAB_REPO_SHA=$(git rev-parse --short HEAD)
    git archive --format=tar main | bzip2 -c > "$BACKUP_STAGING_PATH/homelab-repo.$HOMELAB_REPO_SHA.tar.bz2"

    popd > /dev/null

    rm -rf "${TEMP_REPO_PATH:?}/"
fi
