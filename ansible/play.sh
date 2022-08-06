#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset
DIR="$(dirname "$(readlink -f "$0")")"

cleanup () {
  local ERR_CODE=$?
  popd > /dev/null

  if [ $ERR_CODE -ne 0 ]; then
    echo !! run failed
  fi

  exit $ERR_CODE
}

pushd "$DIR" > /dev/null
trap cleanup EXIT
ERR_CODE=0

if [ -z "$1" ]; then
  echo "usage: $(basename "$0") <playbook name>"
  exit 1
fi

set +o nounset
NAME=$1
set -o nounset

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i hosts.yml "${NAME}.playbook.yml"
