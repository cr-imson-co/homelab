#
# cr.imson.co
#
# nginx cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

# note: www-data exists only on some OS's...maybe make this more configurable?
directory node['configs']['nginx']['htpasswd_path'] do
  owner 'root'
  group 'www-data'
  mode '0740'
  action :create
end

htpasswd_files = [
  'docker.cr.imson.co',
]
htpasswd_files.each do |htpasswd_file|
  remote_file "#{node['configs']['nginx']['htpasswd_path']}/#{htpasswd_file}" do
    source "file://#{node['secrets']['htpasswd_file_location']}/#{htpasswd_file}"
    owner 'root'
    group 'www-data'
    mode '0640'
    action :create
  end
end

