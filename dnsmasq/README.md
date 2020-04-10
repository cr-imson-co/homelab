# dnsmasq configuration

dnsmasq is used to override dns settings for special LAN configuration.

Whilst domains may be pointed externally at a remote server, we want to loop them around to point to our home lab infrastructure when...at home.
And if we're VPN'd in, we can just run another dnsmasq instance that overrides that domain (again) to point to our home lab infrastructure, assuming that OpenVPN clients are configured to create an accessible VPN mesh.

## `vpn/`

`vpn/` is a vpn-specific dnsmasq configuration file.  Copy it into `/etc/dnsmasq.d/`.

## `lan/`

`lan/` is a lan-specific dnsmasq configuration file.  Copy it into `/etc/dnsmasq.d/`.
Note that pihole leverages dnsmasq.
