#!/bin/bash
#
# cr.imson.co
#
# chef configuration file generation
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset
DIR="$(dirname "$(readlink -f "$0")")"

CHEF_CONFIG_DIR=/srv/chef
SECRETS_FILE=$CHEF_CONFIG_DIR/secrets.json

if [ "$EUID" -ne 0 ]; then
  echo !! script must be run as root, bailing.
  exit 1
fi

pushd "$DIR" > /dev/null

if [ ! -d $CHEF_CONFIG_DIR/ ]; then
  mkdir $CHEF_CONFIG_DIR/
  chmod 0700 $CHEF_CONFIG_DIR/
  chown root:root $CHEF_CONFIG_DIR/
fi

if [ ! -f $SECRETS_FILE ]; then
  echo {} > $SECRETS_FILE
  chmod 0600 $SECRETS_FILE
  chown root:root $SECRETS_FILE
fi

SECRETS_FILE=$SECRETS_FILE /opt/chef/embedded/bin/erb "$DIR/cookbooks/homelab.json.erb" >| $CHEF_CONFIG_DIR/homelab.json
chmod 600 $CHEF_CONFIG_DIR/homelab.json
chown root:root $CHEF_CONFIG_DIR/homelab.json

set +o nounset
chef-solo \
  --chef-license accept-silent \
  --json-attributes $CHEF_CONFIG_DIR/homelab.json \
  --local-mode \
  --config "$DIR/solo.rb" \
  -o "$1"
set -o nounset

popd > /dev/null
