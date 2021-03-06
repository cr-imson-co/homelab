#
# cr.imson.co
#
# docker cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

cookbook_file "#{node['configs']['docker']['scripts_path']}/docker-compose.yml" do
  source 'docker-compose.yml'
  owner 'root'
  group 'docker'
  mode '0640'
  action :create
end

cookbook_file "#{node['configs']['docker']['scripts_path']}/start.sh" do
  source 'start.sh'
  owner 'root'
  group 'docker'
  mode '0750'
  action :create
end

cookbook_file "#{node['configs']['docker']['scripts_path']}/stop.sh" do
  source 'stop.sh'
  owner 'root'
  group 'docker'
  mode '0750'
  action :create
end

cookbook_file "#{node['configs']['docker']['scripts_path']}/restart.sh" do
  source 'restart.sh'
  owner 'root'
  group 'docker'
  mode '0750'
  action :create
end

cookbook_file "#{node['configs']['docker']['scripts_path']}/update.sh" do
  source 'update.sh'
  owner 'root'
  group 'docker'
  mode '0750'
  action :create
end

# todo: write secrets files for the various database passwords
# files should not contain newlines!
