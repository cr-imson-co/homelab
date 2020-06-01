#
# cr.imson.co
#
# volume-backup cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

cookbook_file "#{node['configs']['docker']['hook_path']}/pre-backup/backup-repo.sh" do
  source 'pre-backup/backup-repo.sh'
  mode '0740'
  owner 'root'
  group 'docker'
  action :create
end
