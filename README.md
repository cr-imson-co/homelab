![homelab logo](/homelab.png)

### scripts, configuration, and more

#### `assets/`

image assets for the `cr.imson.co` icons / logos.

#### `cookbooks/certsync/`

cookbook which deploys the certsync service, which fetches certpackage-wadded LetsEncrypt certificates and deploys them for use with nginx-proxy.

#### `cookbooks/homelab/`

cookbook which deploys the homelab.

#### `cookbooks/homelab_proxy/`

cookbook which deploys the homelab reverse proxy, which fronts several services such as pihole, the NAS, and the unifi controller.

#### `cookbooks/mounts/`

cookbook which deploys the network filesystem mounts and mount-check services.

#### `cookbooks/nginx/`

cookbook which deploys the nginx configuration files, including the static site and any other necessities for dockerized nginx.

#### `cookbooks/notifications/`

cookbook which deploys the system notification scripts.

#### `cookbooks/volume-backup/`

cookbook which deploys the volume-backup service, which handles backing up docker images, volumes, and more to another location.

#### `certpackage/`

certpackage service which bundles up live LetsEncrypt certificates for replication and reuse in a LAN environment.

#### `dnsmasq/`

dnsmasq configuration files for a VPN and LAN environment to better enable access to home lab provided services.

### todo

convert to ansible. chef licensing is dumb.
