#
# cr.imson.co
#
# docker hooks cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

cookbook_file "#{node['configs']['docker']['hook_path']}/hook.sh" do
  source 'hook.sh'
  mode '0770'
  owner 'root'
  group 'docker'
  action :create
end

# create hook directories
docker_hooks = [
  'pre-start',
  'post-start',
  'pre-stop',
  'post-stop',
  'pre-update',
  'post-update',
]
docker_hooks.each do |docker_hook|
  directory "#{node['configs']['docker']['hook_path']}/#{docker_hook}" do
    mode '0770'
    owner 'root'
    group 'docker'
    action :create
  end
end
