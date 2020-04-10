# certsync service

This service handles pulling down and populating `/etc/nginx/certs/` with LetsEncrypt certificates on a regular basis.

## requirements

This service requires a user named "certsync" to exist on both the local and remote servers.  
The user should have an `.ssh/config` entry declaring the server's ssh details, a generated SSH keypair (RSA, ed25519, whatever), and the public key being added to the authorized_keys file on the remote system.

## `systemd/`

`systemd/` contains `certsync.timer` and `certsync.service` (a timer definition file and a service file respectively) so that systemd will run certsync regularly.
These should be placed in `/lib/systemd/system/`.

## `bin/`

`bin/` contains the scripts that are the guts of the certsync service.
These should be placed in `/usr/local/bin/`.

`bin/certfetch.sh` should be chmod'd to 0754, and owned by `root:certsync` so that the `certsync` user can run the script but not modify it.
