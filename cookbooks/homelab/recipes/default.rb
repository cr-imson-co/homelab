#
# cr.imson.co
#
# homelab cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

include_recipe 'homelab::config'
include_recipe 'notifications::default'
include_recipe 'docker::hooks'
include_recipe 'certsync::default'
include_recipe 'nginx::default'
include_recipe 'mounts::backup-mount'
include_recipe 'mounts::mount-check'
include_recipe 'volume-backup::default'
include_recipe 'volume-backup::backup-repo-hook'
include_recipe 'volume-backup::check-backup-mount-hook'
include_recipe 'volume-backup::notify-success-hook'

include_recipe 'docker::default'
