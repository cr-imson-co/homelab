#!/bin/bash
#
# cr.imson.co
#
# lets-encrypt subdomain management scripts
# @author Damian Bushong <katana@odios.us>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

if [ "$EUID" -ne 0 ]; then
  echo !! script must be run as root, bailing.
  exit 1
fi

set +o nounset
if [ -z "$1" ]; then
    echo usage: $0 \<subdomain\>
    echo note: subdomain should not include the domain itself.
    exit 1
fi

SUBDOMAIN=$1
set -o nounset

DOMAIN=$SUBDOMAIN.cr.imson.co

echo :: this script will delete the configuration and certificates
echo "   used to renew the domain ${DOMAIN}"
echo ""
echo :: please double-check the subdomain!

read -p "   proceed? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo :: deleting ${DOMAIN} via certbot
    certbot delete --cert-name ${DOMAIN} || true

    echo :: deleting nginx configurations if present
    rm -f /etc/nginx/sites-enabled/${DOMAIN} || true
    rm -f /etc/nginx/sites-available/${DOMAIN} || true

    echo :: reloading nginx
    systemctl reload nginx

    echo :: deletion completed
else
    echo !! aborting
fi
