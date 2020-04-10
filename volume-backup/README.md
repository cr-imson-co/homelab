# volume-backup service

This service handles regularly creating backups of Docker volumes.

## requirements

This service requires samba by default, but can copy the backups to anywhere on the filesystem.
Creating a samba credentials file at `/etc/samba/credentials/backup` is required to use samba.

## `systemd/`

`systemd/` contains `volume-backup.timer`, `volume-backup.service` (a timer definition file, a service file, and a mount definition file respectively) so that systemd will run volume-backup regularly.
These should be placed in `/lib/systemd/system/`.

## `bin/`

`bin/` contains the script that is the guts of the volume-backup service.
This should be placed in `/usr/local/bin/`.

## `docker-hooks`

This service has the following service-specific docker hooks:

- `cleanup-backup`
- `move-backup`
- `backup-volume`
- `backup-image`
