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
MAX_RETRIES=5

echo :: please ensure that ${DOMAIN} has a DNS A record present.
read -p "   Press [Enter] key to continue..."

if [ ! -f /etc/nginx/sites-available/${DOMAIN} ]; then
    echo :: nginx sites-available file does not exist - creating one.
    cat <<- EOH > /etc/nginx/sites-available/${DOMAIN}
        server {
            server_name ${DOMAIN};
            root /srv/html;
            index index.html;
            location / {
                try_files \$uri \$uri/ =404;
            }
        }
EOH
fi

if [ ! -f /etc/nginx/sites-enabled/${DOMAIN} ]; then
    echo :: nginx sites-enable symlink does not exist - creating one.
    ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled
fi

echo :: reloading nginx
systemctl reload nginx

HOST_EXISTS=1
for i in $(seq $MAX_RETRIES); do
    echo :: checking for DNS A record

    set +o errexit
    host ${DOMAIN} 8.8.8.8
    HOST_EXISTS=$?
    set -o errexit

    if [ $HOST_EXISTS -eq 0 ]; then
        break
    fi

    echo ?? DNS A record not found; sleeping for 30s and retrying...
    sleep 30
done

if [ $HOST_EXISTS -eq 1 ]; then
    echo !! DNS A record still does not exist, bailing.
    exit 1
fi

echo :: running certbot

certbot --nginx -d ${DOMAIN}

echo :: certbot done
echo :: running certpackage

systemctl start certpackage.service

echo :: subdomain certificates created
