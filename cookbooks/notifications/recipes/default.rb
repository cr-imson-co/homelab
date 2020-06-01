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

cookbook_file "#{node['configs']['global']['local_bin_path']}/notification.sh" do
  source 'notification.sh'
  mode '0740'
  owner 'root'
  group 'staff'
  action :create
end

cookbook_file "#{node['configs']['global']['local_bin_path']}/failure_notification.sh" do
  source 'failure_notification.sh'
  mode '0740'
  owner 'root'
  group 'staff'
  action :create
end

# note: not using systemd_unit because of chef issues with certain types of systemd units
cookbook_file "#{node['configs']['global']['systemd_unit_path']}/failure-notification@.service" do
  source 'failure-notification@.service'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
end

package 'python3-pip' do
  options '--no-install-recommends'
end

package 'python3-setuptools' do
  options '--no-install-recommends'
end

execute 'pip_install_apprise' do
  command "pip3 install -r #{node['configs']['homelab']['config_path']}/apprise_requirements.txt"
  action :nothing
end

cookbook_file "#{node['configs']['homelab']['config_path']}/apprise_requirements.txt" do
  source 'apprise_requirements.txt'
  mode '0740'
  owner 'root'
  group 'staff'
  action :create
  notifies :run, 'execute[pip_install_apprise]', :immediately
end
