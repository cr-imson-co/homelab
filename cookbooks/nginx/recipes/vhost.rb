#
# cr.imson.co
#
# nginx cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

directory node['configs']['nginx']['vhost_path'] do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

vhost_files = [
  'cloud.cr.imson.co',
  'docker.cr.imson.co',
]
vhost_files.each do |vhost_file|
  cookbook_file "#{node['configs']['nginx']['vhost_path']}/#{vhost_file}" do
    source "vhost.d/#{vhost_file}"
    owner 'root'
    group 'root'
    mode '0600'
    action :create
  end
end
