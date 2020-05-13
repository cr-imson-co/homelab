#
# cr.imson.co
#
# nginx cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

# note: this directory is populated by the certpackage/certsync services
directory node['configs']['nginx']['certs_path'] do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end
