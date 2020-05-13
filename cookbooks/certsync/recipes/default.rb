#
# cr.imson.co
#
# certsync cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

# todo: create or validate that the certsync user exists
# todo: generate ssh key on the fly?

execute 'systemd_daemon_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

cookbook_file "#{node['configs']['global']['local_bin_path']}/certfetch.sh" do
  source 'certfetch.sh'
  mode '0750'
  owner 'root'
  group 'certsync'
  action :create
end

cookbook_file "#{node['configs']['global']['local_bin_path']}/certsync.sh" do
  source 'certsync.sh'
  mode '0740'
  owner 'root'
  group 'staff'
  action :create
end

# note: not using systemd_unit because of chef issues with certain types of systemd units
# todo: use templates for the service to parameterize the local bin path?

cookbook_file "#{node['configs']['global']['systemd_unit_path']}/certsync.service" do
  source 'certsync.service'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
end

cookbook_file "#{node['configs']['global']['systemd_unit_path']}/certsync.timer" do
  source 'certsync.timer'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
end

service 'certsync.timer' do
  action :enable
end
