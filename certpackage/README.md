# certpackage service

This service handles regularly creating tarballs of LetsEncrypt certificates for use with the certsync service.

## requirements

This service requires a user named "certsync" to exist on the remote server.

## `systemd/`

`systemd/` contains `certpackage.timer` and `certpackage.service` (a timer definition file and a service file respectively) so that systemd will run certsync regularly.
These should be placed in `/lib/systemd/system/`.

## `bin/`

`bin/` contains the script that is the guts of the certpackage service.
This should be placed in `/usr/local/bin/`.
