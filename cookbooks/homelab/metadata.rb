name 'homelab'
maintainer 'Damian Bushong'
maintainer_email 'katana@odios.us'
license 'MIT'
description 'Installs/Configures homelab'
version '1.0.0'
chef_version '>= 14.0'
depends 'notifications'
depends 'docker'
depends 'certsync'
depends 'mounts'
depends 'nginx'
depends 'volume-backup'
