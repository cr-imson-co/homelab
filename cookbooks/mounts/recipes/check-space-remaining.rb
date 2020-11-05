#
# cr.imson.co
#
# mounts cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

execute 'systemd_daemon_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

cookbook_file "#{node['configs']['global']['local_bin_path']}/check-space-remaining.sh" do
  source 'check-space-remaining.sh'
  mode '0740'
  owner 'root'
  group 'staff'
  action :create
end

# note: not using systemd_unit because of chef issues with certain types of systemd units
# todo: use templates for the service to parameterize the local bin path?

cookbook_file "#{node['configs']['global']['systemd_unit_path']}/check-space-remaining.service" do
  source 'check-space-remaining.service'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
end

cookbook_file "#{node['configs']['global']['systemd_unit_path']}/check-space-remaining.timer" do
  source 'check-space-remaining.timer'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
end

service 'check-space-remaining.timer' do
  action :enable
end
