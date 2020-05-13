#
# cr.imson.co
#
# volume-backup cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

cookbook_file "#{node['configs']['docker']['hook_path']}/pre-backup/check-backup-mount.sh" do
  source 'pre-backup/check-backup-mount.sh'
  mode '0750'
  owner 'root'
  group 'docker'
  action :create
end
