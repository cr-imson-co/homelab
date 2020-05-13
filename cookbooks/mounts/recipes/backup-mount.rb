#
# cr.imson.co
#
# mounts cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

# todo: make mount target directory dynamically if it doesn't exist
mount_name = 'backup'

execute 'systemd_daemon_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service "mnt-#{mount_name}.mount" do
  action :nothing
end

template "#{node['configs']['mount']['samba_credentials_path']}/backup" do
  source 'samba_credentials.erb'
  mode '0600'
  owner 'root'
  group 'root'
  sensitive true
  action :create
  variables(
    username: node['secrets']['samba_backup_username'],
    password: node['secrets']['samba_backup_password']
  )
end

template "#{node['configs']['global']['systemd_unit_path']}/mnt-#{mount_name}.mount" do
  source 'unit.mount.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
  notifies :restart, "service[mnt-#{mount_name}.mount]", :delayed
  variables(
    mount_name: mount_name
  )
end

