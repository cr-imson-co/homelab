#!/bin/bash
#
# cr.imson.co
#
# certsync service
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env
set -o errexit -o pipefail -o noclobber -o nounset
# DIR="$(dirname "$(readlink -f "$0")")"

# configuration
. /srv/homelab/homelab_config.sh
. "$HOMELAB_CONFIG_PATH/global_config.sh"
. "$HOMELAB_CONFIG_PATH/certsync_config.sh"
. "$HOMELAB_CONFIG_PATH/docker_config.sh"

# import the dockercompose function
. "$DOCKER_SCRIPTS_PATH/common.sh"

# run the certfetch script first (as the certsync user)
sudo -u "$CERTSYNC_USERNAME" "$GLOBAL_LOCAL_BIN_PATH/certfetch.sh"

# we *must* require that unpacked certs be present
if [ ! -d "$CERTSYNC_UNPACK_PATH" ]; then
  echo !! CERTS NOT PRESENT, BAILING OUT
  exit 1
fi

# iterate over the various directories unpacked
#
# each directory holds the certificates for a single LetsEncrypt domain certificate
#   and is named after the domain.
for d in "$CERTSYNC_UNPACK_PATH"/*/ ; do
  SOURCE=${d%/}
  DIRNAME=${SOURCE##*/}

  # iterate over the certificates and copy them all into place
  for f in "$SOURCE"/*.pem ; do
    FILENAME=${f##*/}

    if [ ! -d "$CERTSYNC_DEPLOY_PATH/$DIRNAME"/ ]; then
      mkdir -p "$CERTSYNC_DEPLOY_PATH/$DIRNAME"
      chmod og-rx "$CERTSYNC_DEPLOY_PATH/$DIRNAME"

      echo :: created "$CERTSYNC_DEPLOY_PATH/$DIRNAME" for the first time
    fi

    cp "$f" "$CERTSYNC_DEPLOY_PATH/$DIRNAME/$FILENAME"
    chmod og-rx "$CERTSYNC_DEPLOY_PATH/$DIRNAME/$FILENAME"
    echo :: copied "$f" to "$CERTSYNC_DEPLOY_PATH/$DIRNAME/$FILENAME"
  done

  # create the symlinks to each certificate file as necessary
  if [ ! -L "$CERTSYNC_DEPLOY_PATH/$DIRNAME.crt" ]; then
    ln -s "$CERTSYNC_DEPLOY_PATH/$DIRNAME/fullchain.pem" "$CERTSYNC_DEPLOY_PATH/$DIRNAME.crt"
    echo :: created fullchain symlink for "$DIRNAME"
  fi

  if [ ! -L "$CERTSYNC_DEPLOY_PATH/$DIRNAME.key" ]; then
    ln -s "$CERTSYNC_DEPLOY_PATH/$DIRNAME/privkey.pem" "$CERTSYNC_DEPLOY_PATH/$DIRNAME.key"
    echo :: created privkey symlink for "$DIRNAME"
  fi

  if [ ! -L "$CERTSYNC_DEPLOY_PATH/$DIRNAME.chain.pem" ]; then
    ln -s "$CERTSYNC_DEPLOY_PATH/$DIRNAME/chain.pem" "$CERTSYNC_DEPLOY_PATH/$DIRNAME.chain.pem"
    echo :: created chain symlink for "$DIRNAME"
  fi

  if [ ! -L "$CERTSYNC_DEPLOY_PATH/$DIRNAME.dhparam.pem" ]; then
    ln -s "$CERTSYNC_DEPLOY_PATH/ssl-dhparams.pem" "$CERTSYNC_DEPLOY_PATH/$DIRNAME.dhparam.pem"
    echo :: created dhparam symlink for "$DIRNAME"
  fi
done

# clean up after ourselves
[ -e "$CERTSYNC_UNPACK_PATH" ] && rm -rf "$CERTSYNC_UNPACK_PATH"

# bounce the nginx proxy to ensure we have the latest certs loaded
dockercompose restart nginx-proxy || true
