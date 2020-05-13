#
# cr.imson.co
#
# nginx cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

directory node['configs']['nginx']['root_path'] do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end
