# redbooru local test environment

This is the docker-compose based configuration for the redbooru local test environment.

A working installation of `docker` and `docker-compose` is expected.

## requirements

Create the following files beside the `docker-compose.yml` file:

- `mysql_root_password`
- `mysql_password`

These should never be checked into git, and should contain the desired passwords for various services.

## deploying

Run the `deploy.sh` file as `root`.
