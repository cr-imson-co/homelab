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
SYNC_USER=certsync
TARBALL_PATH=/home/$SYNC_USER/le-certs.tgz
CERT_PATH=/etc/letsencrypt/live/

[ -e $TARBALL_PATH ] && rm $TARBALL_PATH
tar czhf $TARBALL_PATH -C $CERT_PATH .
chown $SYNC_USER:users $TARBALL_PATH
