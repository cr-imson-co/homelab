#
# cr.imson.co
#
# homer cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

directory node['configs']['homer']['root_path'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory "#{node['configs']['homer']['root_path']}/icons" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

asset_files = [
  'config.yml',
  'custom.css',
  'icons/favicon-16x16.png',
  'icons/favicon-32x32.png',
  'icons/crimson.logo_512_t.png',
]
asset_files.each do |asset_file|
  cookbook_file "#{node['configs']['homer']['root_path']}/#{asset_file}" do
    source asset_file.to_s
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end
