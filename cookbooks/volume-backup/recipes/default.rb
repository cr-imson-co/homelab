#
# cr.imson.co
#
# volume-backup cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

execute 'systemd_daemon_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

cookbook_file "#{node['configs']['global']['local_bin_path']}/volume-backup.sh" do
  source 'volume-backup.sh'
  mode '0744'
  owner 'root'
  group 'staff'
  action :create
end

# note: not using systemd_unit because of chef issues with certain types of systemd units

cookbook_file "#{node['configs']['global']['systemd_unit_path']}/volume-backup.service" do
  source 'volume-backup.service'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
end

cookbook_file "#{node['configs']['global']['systemd_unit_path']}/volume-backup.timer" do
  source 'volume-backup.timer'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
end

# create hook directories
docker_hooks = [
  'pre-backup',
  'post-backup',
  'snapshot-backup',
  'cleanup-backup',
  'move-backup',
  'backup-volume',
  'backup-image',
]
docker_hooks.each do |docker_hook|
  directory "#{node['configs']['docker']['hook_path']}/#{docker_hook}" do
    mode '0750'
    owner 'root'
    group 'docker'
    action :create
  end
end

service 'volume-backup.timer' do
  action :enable
end

