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
DOCKER_PROJECT_NAME=docker
YML_PATH=/srv/docker
STAGING_PATH=/opt/volume-backup
BACKUP_PATH=/mnt/backup
DOCKER_HOOK_PATH=/srv/docker/hooks

BACKUP_TIME=$(date +%s)

VOLUME_DESC=
SERVICE_DESC=
HOSTNAME=$(cat /etc/hostname)
HUMANE_TIME=$(date --date="@$BACKUP_TIME")
BACKUP_SUBPATH=$BACKUP_PATH/backup_$BACKUP_TIME

dockercompose () {
  docker-compose --log-level ERROR -f $YML_PATH/docker-compose.yml -p $DOCKER_PROJECT_NAME $@
}

set +o errexit
systemctl is-active mnt-backup.mount --quiet
BACKUP_FS_MOUNTED=$?
set -o errexit

if [ $BACKUP_FS_MOUNTED -ne 0 ]; then
  echo !! backup network filesystem is not mounted!
  echo :: attempting to mount...
  # note - if mounting fails, this *should* also fail, but we should
  #   double-check afterward still
  systemctl start mnt-backup.mount --quiet

  set +o errexit
  systemctl is-active mnt-backup.mount --quiet
  BACKUP_FS_MOUNTED=$?
  set -o errexit

  if [ $BACKUP_FS_MOUNTED -ne 0 ]; then
    echo !! still failed to mount backup network filesystem, bailing
    exit 1
  fi
fi

# need to grab services and volumes currently in use
SERVICES=$(dockercompose config --services)
VOLUMES=$(dockercompose config --volumes)
declare -A SERVICES_TO_IMAGE_NAMES
declare -A SERVICES_TO_IMAGE_IDS

# import the hook functions
. $DOCKER_HOOK_PATH/hook.sh

# obtain some info for the services currently running...
for SERVICE in $SERVICES; do
  CONTAINER_ID=$(dockercompose ps -q $SERVICE)

  SERVICES_TO_IMAGE_NAMES[$SERVICE]=$(docker inspect --format='{{.Config.Image}}' $CONTAINER_ID)
  SERVICES_TO_IMAGE_IDS[$SERVICE]=$(dockercompose images -q $SERVICE)
done

# just in case a prior run failed or something...
echo :: preparing staging directory...
[ -e $STAGING_PATH/.backup_metadata ] && rm $STAGING_PATH/.backup_metadata
[ -e $STAGING_PATH/docker-compose.yml.bz2 ] && rm $STAGING_PATH/docker-compose.yml.bz2
find $STAGING_PATH/ -name "*.tar.bz2" -exec rm {} \;

hook cleanup-backup $STAGING_PATH

echo :: snapshotting current docker-compose file...
bzip2 -c $YML_PATH/docker-compose.yml > $STAGING_PATH/docker-compose.yml.bz2

echo :: backing up homelab repo...
git clone --depth 1 git@gitlab.cr.imson.co:cr.imson.co/homelab.git $STAGING_PATH/homelab-git
pushd $STAGING_PATH/homelab-git/ > /dev/null
HOMELAB_REPO_SHA=$(git rev-parse --short=8 HEAD)
git archive --format=tar master | bzip2 -c > $STAGING_PATH/homelab-repo.$HOMELAB_REPO_SHA.tar.bz2
popd > /dev/null
rm -rf $STAGING_PATH/homelab-git/

hook pre-stop

echo :: stopping containers...
dockercompose down

hook post-stop

# containers MUST be stopped in order to back volumes up safely
#   because we don't want things getting half-written
#   or fight with file locks. better to abort and panic.
echo :: verifying that containers are no longer running
if [[ ! -z $(dockercompose ps -q) ]]; then
  echo !! containers are still running even after down request, bailing
  exit 1
fi

echo :: beginning volume exports...
for _VOLUME in $VOLUMES; do
  VOLUME=${DOCKER_PROJECT_NAME}_${_VOLUME}

  echo :: backing up $VOLUME to staging directory
  docker run -v $VOLUME:/volume -v $STAGING_PATH:/backup --rm loomchild/volume-backup backup $VOLUME

  hook backup-volume $STAGING_PATH $VOLUME
done

echo :: beginning image exports...
for SERVICE in $SERVICES; do
  IMAGE_ID=${SERVICES_TO_IMAGE_IDS[$SERVICE]}
  SHORT_IMAGE_ID=${IMAGE_ID:0:9}

  echo :: backing up $SERVICE image \($SHORT_IMAGE_ID\)
  docker save $IMAGE_ID | bzip2 > $STAGING_PATH/image_$IMAGE_ID.tar.bz2

  hook backup-image $STAGING_PATH $IMAGE_ID $SERVICE
done

hook pre-start

echo :: starting containers back up...
dockercompose up -d

hook post-start

echo :: creating metadata file...

for SERVICE in $SERVICES; do
  IMAGE_ID=${SERVICES_TO_IMAGE_IDS[$SERVICE]}
  FILESIZE=$(stat --printf="%s" $STAGING_PATH/image_$IMAGE_ID.tar.bz2)
  HUMANE_SIZE=$(numfmt --to=iec-i --suffix=B --format="%.3f" $FILESIZE)
  SHA256_CHECKSUM=$(sha256sum $STAGING_PATH/image_$IMAGE_ID.tar.bz2 | cut -d " " -f 1)

  SERVICE_DESC+="$SERVICE"
  SERVICE_DESC+=$'\n'
  SERVICE_DESC+="-- image name: ${SERVICES_TO_IMAGE_NAMES[$SERVICE]}"
  SERVICE_DESC+=$'\n'
  SERVICE_DESC+="-- image id: ${SERVICES_TO_IMAGE_IDS[$SERVICE]}"
  SERVICE_DESC+=$'\n'
  SERVICE_DESC+="-- image size: $HUMANE_SIZE (${FILESIZE} B)"
  SERVICE_DESC+=$'\n'
  SERVICE_DESC+="-- image sha256: $SHA256_CHECKSUM"
  SERVICE_DESC+=$'\n'
done
for _VOLUME in $VOLUMES; do
  VOLUME=${DOCKER_PROJECT_NAME}_${_VOLUME}
  FILESIZE=$(stat --printf="%s" $STAGING_PATH/$VOLUME.tar.bz2)
  HUMANE_SIZE=$(numfmt --to=iec-i --suffix=B --format="%.3f" $FILESIZE)
  SHA256_CHECKSUM=$(sha256sum $STAGING_PATH/$VOLUME.tar.bz2 | cut -d " " -f 1)

  VOLUME_DESC+="$VOLUME"
  VOLUME_DESC+=$'\n'
  VOLUME_DESC+="-- size: $HUMANE_SIZE (${FILESIZE} B)"
  VOLUME_DESC+=$'\n'
  VOLUME_DESC+="-- sha256: $SHA256_CHECKSUM"
  VOLUME_DESC+=$'\n'
done

cat << EOF > $STAGING_PATH/.backup_metadata
docker volume-backup script
  running @ $HOSTNAME
  date: $HUMANE_TIME (@$BACKUP_TIME)
services:
$SERVICE_DESC
volumes:
$VOLUME_DESC
EOF

echo :: moving files from staging to backup location...
mkdir -p $BACKUP_SUBPATH
cp $STAGING_PATH/{.backup_metadata,docker-compose.yml.bz2,*.tar.bz2} $BACKUP_SUBPATH

hook move-backup $STAGING_PATH $BACKUP_SUBPATH

echo :: cleaning up staging directory...
rm $STAGING_PATH/.backup_metadata
rm $STAGING_PATH/docker-compose.yml.bz2
rm $STAGING_PATH/*.tar.bz2

hook cleanup-backup $STAGING_PATH

echo :: backup complete
