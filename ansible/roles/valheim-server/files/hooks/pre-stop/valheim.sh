#!/bin/bash
#
# valheim
#
# docker container management scripts
# @author Damian Bushong <katana@codebite.net>
#

# set sane shell env options
set -o errexit -o pipefail -o noclobber -o nounset

/srv/valheim/stop.sh
