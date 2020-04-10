# docker configuration

This is the docker-compose based configuration for the cr.imson.co homelab.

A working installation of `docker` and `docker-compose` is expected.

## requirements

Create the following files in `/srv/docker/`:

- `mysql_root_password`
- `mysql_password`
- `postgres_password`

These should never be checked into git, and should contain the desired passwords for the various services.

Create the file `/srv/registry/config.yml`, using the file `./registry/example-config.yml` as a base.
Only `http.secret` value should need to be changed.

## deploying

Run the `deploy.sh` file as `root`.
