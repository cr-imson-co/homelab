#
# cr.imson.co
#
# nginx cookbook
# @author Damian Bushong <katana@odios.us>
# @license MIT license (see /LICENSE for details)
#

include_recipe 'nginx::rootdir'
include_recipe 'nginx::certs'
include_recipe 'nginx::html'
include_recipe 'nginx::vhost'
