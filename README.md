![homelab logo](/homelab.png)

### scripts, configuration, and more

#### `assets/`

image assets for the `cr.imson.co` icons / logos.

#### `cookbooks/certpackage/`

##### **IN PROGRESS**

cookbook which deploys the certpackage service, which bundles up live LetsEncrypt certificates for replication and reuse in a LAN environment.

#### `cookbooks/certsync/`

cookbook which deploys the certsync service, which fetches certpackage-wadded LetsEncrypt certificates and deploys them for use with nginx-proxy.

#### `cookbooks/homelab/`

cookbook which deploys the homelab.

#### `cookbooks/nginx/`

cookbook which deploys the nginx configuration files, including the static site and any other necessities for dockerized nginx.

#### `cookbooks/volume-backup/`

cookbook which deploys the volume-backup service, which handles backing up docker images, volumes, and more to another location.

#### `certpackage/`

##### **DEPRECATED - to be replaced by `cookbooks/certpackage/`**

certpackage service which bundles up live LetsEncrypt certificates for replication and reuse in a LAN environment.

#### `dnsmasq/`

dnsmasq configuration files for a VPN and LAN environment to better enable access to home lab provided services.

#### `subdomains/`

scripts for managing the creation and cleanup of domains on the external server used with LetsEncrypt.
