#
# cr.imson.co
#
# homelab_proxy config cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

directory node['configs']['homelab_proxy']['config_path'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

asset_files = [
  'default.conf',
]
asset_files.each do |asset_file|
  cookbook_file "#{node['configs']['homelab_proxy']['config_path']}/#{asset_file}" do
    source asset_file.to_s
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end
