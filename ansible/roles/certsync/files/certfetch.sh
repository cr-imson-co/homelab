#!/bin/bash
#
# cr.imson.co
#
# certsync service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

# configuration
. /srv/homelab/global_config.sh
. /srv/homelab/certsync_config.sh
LOCAL_TARBALL_PATH=$GLOBAL_TMP_PATH/$CERTSYNC_TARBALL_NAME
REMOTE_TARBALL_PATH=$CERTSYNC_REMOTE_SERVER:$CERTSYNC_REMOTE_PATH/$CERTSYNC_TARBALL_NAME

# clean up unpack path if it is lingering
[ -e "$CERTSYNC_UNPACK_PATH" ] && rm -rf "$CERTSYNC_UNPACK_PATH"

scp "$REMOTE_TARBALL_PATH" "$LOCAL_TARBALL_PATH"
mkdir -p "$CERTSYNC_UNPACK_PATH"
tar xzf "$LOCAL_TARBALL_PATH" -C "$CERTSYNC_UNPACK_PATH" .
rm "$LOCAL_TARBALL_PATH"
