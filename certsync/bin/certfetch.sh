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
LOCAL_TARBALL_PATH=/tmp/le-certs.tgz
REMOTE_TARBALL_PATH=crimson.odios.us:/home/certsync/le-certs.tgz
UNPACK_PATH=/tmp/le-certs

# clean up unpack path if it is lingering
[ -e $UNPACK_PATH ] && rm -rf $UNPACK_PATH

scp $REMOTE_TARBALL_PATH $LOCAL_TARBALL_PATH
mkdir -p $UNPACK_PATH
tar xzf $LOCAL_TARBALL_PATH -C $UNPACK_PATH .
rm $LOCAL_TARBALL_PATH
