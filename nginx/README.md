# nginx-proxy configuration

## `certs/`

`certs/` will be populated via the `certsync` service, which downloads the LetsEncrypt-generated certificates necessary from the remote server and unpacks them into a structure that nginx-proxy accepts.

Create this directory in `/etc/nginx/`, chmod to `700` and chown to `root:root`.

## `vhost.d/`

`vhost.d/` contains virtualhost-specific nginx configuration entries.

- `docker.cr.imson.co`: No changes needed.

Copy this directory in `/etc/nginx/`, chmod to `700` and chown to `root:root`.

## `htpasswd/`

`htpasswd/` is supposed to be htpasswd files to manage HTTP BASIC authentication for certain domains.
htpasswd files should be created by the htpasswd CLI application in `apache-utils` package, and named the same as the virtualhost they are intended for.

Create this directory in `/etc/nginx/`, chmod to `700` and chown to `root:root`.

## `html/`

`html/` is supposed to be files for the landing page.

Copy this to somewhere like `/srv/html` or something.
