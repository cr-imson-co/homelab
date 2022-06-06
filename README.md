![homelab logo](/homelab.png)

### scripts, configuration, and more

#### `assets/`

image assets for the `cr.imson.co` icons / logos.

#### `ansible/`

ansible playbooks and roles for configuration of the environment.

##### `ansible/configs/`

configuration files used for ansible deployment for systems within the environment.

##### `ansible/secrets/`

secrets files used for ansible deployment for systems within the environment.

##### `ansible/roles/admin/`

configures administrator users to personal preferences, including deployment of dotfiles, configuration of prompts, switching to zsh, etc.

##### `ansible/roles/ansible/`

configures the ansible user used for system configuration and deployments.

##### `ansible/roles/certpackage`

configures the certificate packaging service that resides on the ACME DNS server.

##### `ansible/roles/certsync`

configures the certificate retrieval service that resides in the homelab.

##### `ansible/roles/common`

handles common configuration and package installation.

##### `ansible/roles/disable-init-user`

for systems with an "initial" user (e.g. AWS EC2 ubuntu spins), this disables said initial user.

##### `ansible/roles/docker`

deploys and installs docker-ce.

##### `ansible/roles/docker-nginx`

deploys and configures common nginx-proxy paths

##### `ansible/roles/docker-stack`

deploys configures common docker stack management scripts and hooking capabilities used throughout.

##### `ansible/roles/homelab-homer/`

deploys the homelab configuration for [`homer`](https://github.com/bastienwirtz/homer).

##### `ansible/roles/homelab-landing-page`

deploys and configures landing page assets used in the homelab.

##### `ansible/roles/homelab-notifications`

deploys and configures apprise-based notification capabilities used in the homelab.

##### `ansible/roles/homelab-reverse-proxy`

deploys and configures the nginx reverse proxy configuration used for several internal services in the homelab.

##### `ansible/roles/homelab-share-backup`

deploys and configures the backup network mount used in the homelab.

##### `ansible/roles/homelab-share-containers`

deploys and configures the gitlab container registry mount used in the homelab.

##### `ansible/roles/homelab-share-nextcloud`

deploys and configures the nextcloud network mount used in the homelab.

##### `ansible/roles/homelab-share-registry`

deploys and configures the gitlab package registry network mount used in the homelab.

##### `ansible/roles/init/`

handles initial configuration, hardening, and adjustments for first-touch configuration

##### `ansible/roles/mount-check`

deploys and configures the mount-check service used in the homelab to ensure network mounts are remounted upon disconnect.

necessary because systemd network mounts have no auto-reconnect capabilities by decree of Lennart Poettering and are thus afflicted with a serious amount of *stupid bikeshedding*.

##### `ansible/roles/mount-space-alert`

deploys and configures the mount-space-alert service which dispatches a notification upon warning/critical space remaining thresholds for specified filesystems.

##### `ansible/roles/pihole-lan/`

handles configuration of pihole in the homelab environment (LAN-only).

##### `ansible/roles/raspios/`

handles configuration of raspios based systems.

##### `ansible/roles/ssh/`

handles sshd configuration, hardening, and adjustments.

##### `ansible/roles/updates/`

handles execution of updates and rebooting as necessary.

##### `ansible/roles/volume-backup`

deploys and configures the docker volume backup system.

##### `ansible/roles/wireguard_config/`

wireguard server initial configuration.

##### `ansible/roles/wireguard_client/`

wireguard client installation and configuration.

##### `ansible/roles/wireguard_server/`

wireguard server configuration.
