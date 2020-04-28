# network fileshares & fileshare mounted checking service

This service ensures network fileshares are mounted (because systemd won't, thanks systemd).

## requirements

This service requires samba to be installed, and samba credentials to be created on the filesystem.

* Create a samba credentials file for the backup mount at `/etc/samba/credentials/backup`.
* Create a samba credentials file for the nexus mount at `/etc/samba/credentials/nexus`.

Samba credentials files take the format

```
username=myusername
password=mypassword
```

## `systemd/`

`systemd/` contains `mount-check.timer`, `mount-check.service`, `mnt-backup.mount`, `mnt-nexus.mount` (a timer definition file, a service file, and two mount definition files respectively).
These should be placed in `/etc/systemd/system/`.

## `bin/`

`bin/` contains the script that is the guts of the mount-check service.
This should be placed in `/usr/local/bin/`.

## deployment

Run the deploy script with `sudo ./deploy.sh` to deploy the files to the filesystem.
