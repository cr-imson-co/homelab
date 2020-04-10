![homelab logo](/homelab.png)

### scripts, configuration, and more

#### `assets/`

image assets for the `cr.imson.co` icon / logo.

#### `certpackage/`

certpackage service which bundles up live LetsEncrypt certificates for replication and reuse in a LAN environment.

#### `certsync/`

certsync service which fetches certpackage-wadded LetsEncrypt certificates and deploys them for use with nginx-proxy.

#### `dnsmasq/`

dnsmasq configuration files for a VPN and LAN environment to better enable access to home lab provided services.

#### `docker/`

docker-compose configuration files to define the services provided by the home lab.

#### `docker-hooks/`

A simple set of bash hooks to enable better lifecycle management of the docker-based environment.

#### `nginx/`

nginx-proxy and landing-page configuration.

#### `redbooru-test/`

docker-compose based configuration for the redbooru integration environment.

#### `subdomains/`

scripts for managing the creation and cleanup of domains on the external server used with LetsEncrypt.

#### `volume-backup/`

volume-backup service which backs up Docker volumes to another location.
