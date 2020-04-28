# volume-backup service

This service handles regularly creating backups of Docker volumes.

It is highly recommended to use the external network filesystems in conjunction with this service.

## `systemd/`

`systemd/` contains `volume-backup.timer` and `volume-backup.service` (a timer definition file and a service file respectively) so that systemd will run volume-backup regularly.
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
