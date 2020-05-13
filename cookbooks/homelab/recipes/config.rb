#
# cr.imson.co
#
# homelab config cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

directory node['configs']['homelab']['config_path'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

config_files = [
  'global',
  'homelab',
  'backup',
  'docker',
  'certsync',
  'mount',
]
config_files.each do |config|
  template "#{node['configs']['homelab']['config_path']}/#{config}_config.sh" do
    source 'config.sh.erb'
    mode '0755'
    owner 'root'
    group 'root'
    # sensitive true
    action :create
    variables(
      config_name: config,
      configs: node['configs'][config]
    )
  end
end

template "#{node['configs']['homelab']['config_path']}/secrets_config.sh" do
  source 'config.sh.erb'
  mode '0700'
  owner 'root'
  group 'root'
  sensitive true
  action :create
  variables(
    config_name: 'secret',
    configs: node['secrets']
  )
end
