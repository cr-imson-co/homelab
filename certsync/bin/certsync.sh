#!/bin/bash
#
# cr.imson.co
#
# certsync service
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env
set -o errexit -o pipefail -o noclobber -o nounset
DIR="$(dirname "$(readlink -f "$0")")"

# configuration
YML_PATH=/srv/docker
DOCKER_PROJECT_NAME=docker
CERTSYNC_USER=certsync
UNPACK_PATH=/tmp/le-certs
CERT_PATH=/etc/nginx/certs

dockercompose () {
  docker-compose --log-level ERROR -f $YML_PATH/docker-compose.yml -p $DOCKER_PROJECT_NAME $@
}

# run the certfetch script first (as the certsync user)
sudo -u $CERTSYNC_USER $DIR/certfetch.sh

# we *must* require that unpacked certs be present
if [ ! -d $UNPACK_PATH ]; then
  echo !! CERTS NOT PRESENT, BAILING OUT
  exit 1
fi

# iterate over the various directories unpacked
#
# each directory holds the certificates for a single LetsEncrypt domain certificate
#   and is named after the domain.
for d in $UNPACK_PATH/*/ ; do
  SOURCE=${d%/}
  DIRNAME=${SOURCE##*/}

  # iterate over the certificates and copy them all into place
  for f in $SOURCE/*.pem ; do
    FILENAME=${f##*/}

    if [ ! -d $CERT_PATH/$DIRNAME/ ]; then
      mkdir -p $CERT_PATH/$DIRNAME
      chmod og-rx $CERT_PATH/$DIRNAME

      echo :: created $CERT_PATH/$DIRNAME for the first time
    fi

    cp $f $CERT_PATH/$DIRNAME/$FILENAME
    chmod og-rx $CERT_PATH/$DIRNAME/$FILENAME
    echo :: copied $f to $CERT_PATH/$DIRNAME/$FILENAME
  done

  # create the symlinks to each certificate file as necessary
  if [ ! -L $CERT_PATH/$DIRNAME.crt ]; then
    ln -s $CERT_PATH/$DIRNAME/fullchain.pem $CERT_PATH/$DIRNAME.crt
    echo :: created fullchain symlink for $DIRNAME
  fi

  if [ ! -L $CERT_PATH/$DIRNAME.key ]; then
    ln -s $CERT_PATH/$DIRNAME/privkey.pem $CERT_PATH/$DIRNAME.key
    echo :: created privkey symlink for $DIRNAME
  fi

  if [ ! -L $CERT_PATH/$DIRNAME.chain.pem ]; then
    ln -s $CERT_PATH/$DIRNAME/chain.pem $CERT_PATH/$DIRNAME.chain.pem
    echo :: created chain symlink for $DIRNAME
  fi

  if [ ! -L $CERT_PATH/$DIRNAME.dhparam.pem ]; then
    ln -s $CERT_PATH/ssl-dhparams.pem $CERT_PATH/$DIRNAME.dhparam.pem
    echo :: created dhparam symlink for $DIRNAME
  fi
done

# clean up after ourselves
[ -e $UNPACK_PATH ] && rm -rf $UNPACK_PATH

# bounce the nginx proxy to ensure we have the latest certs loaded
dockercompose restart nginx-proxy
