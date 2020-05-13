#
# cr.imson.co
#
# nginx cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

directory node['configs']['nginx']['html_path'] do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

html_files = [
  'favicon.ico',
  'index.html',
  'shana2.css',
]
html_files.each do |html_file|
  cookbook_file "#{node['configs']['nginx']['html_path']}/#{html_file}" do
    source "html/#{html_file}"
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end
