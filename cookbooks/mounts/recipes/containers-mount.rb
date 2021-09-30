#
# cr.imson.co
#
# mounts cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

mount_name = 'containers'

execute 'systemd_daemon_reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service "mnt-#{mount_name}.mount" do
  action :nothing
end

directory "#{node['configs']['global']['mount_path']}/#{mount_name}" do
  mode '0700'
  owner 993
  group 993
  action :create
end

# template "#{node['configs']['mount']['samba_credentials_path']}/#{mount_name}" do
#   source 'samba_credentials.erb'
#   mode '0600'
#   owner 'root'
#   group 'root'
#   sensitive true
#   action :create
#   variables(
#     username: node['secrets']['samba_gitlab_registry_username'],
#     password: node['secrets']['samba_gitlab_registry_password']
#   )
# end

template "#{node['configs']['global']['systemd_unit_path']}/mnt-#{mount_name}.mount" do
  source 'unit.mount.erb'
  mode '0644'
  owner 'root'
  group 'root'
  action :create
  notifies :run, 'execute[systemd_daemon_reload]', :delayed
  notifies :enable, "service[mnt-#{mount_name}.mount]", :delayed
  notifies :restart, "service[mnt-#{mount_name}.mount]", :delayed
  variables(
    remote_mount_name: "registry/#{mount_name}",
    mount_name: mount_name,
    cred_name: 'registry',
    mount_options: ',uid=993,gid=993,file_mode=0700,dir_mode=0700'
  )
end


