#!/usr/bin/env python3
''' Builds the wireguard client configuration file '''
from __future__ import annotations

import argparse
from dataclasses import dataclass
import ipaddress
import json
import logging
import os
from pathlib import Path
import subprocess
import sys
import textwrap
from typing import Union

# set up logging configuration - only to stdout/stderr for now
class ErrorLogFilter(logging.Filter):
    ''' prevents error logs from making it into stdout '''
    def __init__(self, name: str = 'ErrorLogFilter') -> None:
        super().__init__(name)

    def filter(self, record):
        return record.levelno < logging.WARNING

logger = logging.getLogger('build')
log_formatter = logging.Formatter(
    '[%(asctime)s] (%(name)s:%(levelname)s) %(message)s',
    '%Y-%m-%dT%H:%M:%S%z'
)

log_stdout_handler = logging.StreamHandler(sys.stdout)
log_stdout_handler.addFilter(ErrorLogFilter())
log_stdout_handler.setFormatter(log_formatter)

log_stderr_handler = logging.StreamHandler(sys.stderr)
log_stderr_handler.setFormatter(log_formatter)
log_stderr_handler.setLevel(logging.WARNING)

logger.addHandler(log_stdout_handler)
logger.addHandler(log_stderr_handler)

logger.setLevel(logging.INFO)

WG_BIN = os.environ.get('WG_BIN', '/usr/bin/wg')

def call_wg(wg_args: str, stdin: Union[str, None] = None):
    ''' make a call to wg binary via a subprocess invoke '''

    call = f'{WG_BIN} {wg_args}'
    logger.debug(f'running wg call: {call}')

    try:
        if stdin:
            output = subprocess.check_output(
                call.split(' '),
                input=stdin,
                text=True
            )
        else:
            output = subprocess.check_output(
                call.split(' '),
                text=True
            )

        logger.debug('wg call ran without errors')

        return output.strip()
    except subprocess.CalledProcessError as ex:
        logger.error(f'wg call failed with status code {ex.returncode}')
        raise ex

def port_range(arg):
    ''' Port range validation helper for argparse. '''

    try:
        port = int(arg)
    except ValueError as ex:
        raise argparse.ArgumentTypeError('must be an integer') from ex

    if port < 0 or port > 65535:
        raise argparse.ArgumentTypeError('must be a valid port number (0-65535)')

    return port

@dataclass
class ServerIdentity:
    ''' Represents the server "identity" for details required by the client when building the Wireguard client configuration. '''

    vpn_endpoint: str
    vpn_port: int

    vpn_network: ipaddress.IPv4Network
    vpn_public_key: str

    dns_ip: Union[ipaddress.IPv4Address, None]

    @staticmethod
    def from_json(payload: str) -> ServerIdentity:
        ''' Load the server identity from the identity JSON file. '''

        identity = json.loads(payload)
        identity['vpn_network'] = ipaddress.IPv4Network(identity['vpn_network'])
        if identity['dns_ip']:
            identity['dns_ip'] = ipaddress.IPv4Address(identity['dns_ip'])

        return ServerIdentity(**identity)

@dataclass
class WireguardClientConfig:
    ''' Handles the client configuration generation for the Wireguard client. '''

    vpn_ip: ipaddress.IPv4Address
    allowed_ips: ipaddress.IPv4Network

    private_key: str = ''
    public_key: str = ''
    preshared_key: str = ''

    use_vpn_dns: bool = False
    use_keepalive: bool = False

    def gen_client_keys(self):
        ''' generate wireguard client keys '''

        self.private_key = call_wg('genkey')
        self.public_key = call_wg('pubkey', self.private_key)
        self.preshared_key = call_wg('genpsk')

    def create_client_config(self, server: ServerIdentity) -> str:
        ''' Build a complete Wireguard configuration file, given an appropriate server config. '''

        dns_line = f'DNS = {server.dns_ip}' if self.use_vpn_dns and server.dns_ip else ''
        keepalive_line = 'PersistentKeepalive = 25' if self.use_keepalive else ''

        config = f'''
            [Interface]
            Address = {self.vpn_ip}/{server.vpn_network.prefixlen}
            ListenPort = {server.vpn_port}
            PrivateKey = {self.private_key}
            {dns_line}

            [Peer]
            PublicKey = {server.vpn_public_key}
            PresharedKey = {self.preshared_key}
            AllowedIPs = {self.allowed_ips.with_prefixlen}
            Endpoint = {server.vpn_endpoint}:{server.vpn_port}
            {keepalive_line}
        '''.rstrip('\n')

        return textwrap.dedent(config).lstrip('\n')

    def create_client_identity(self) -> str:
        ''' Create a client identity fragment to assist in building the server identity file. '''

        identity = {
            'vpn_ip': str(self.vpn_ip),
            'public_key': self.public_key,
            'preshared_key': self.preshared_key
        }

        return json.dumps(identity, indent=2)

def main(
        vpn_ip: ipaddress.IPv4Address,
        allowed_ips: ipaddress.IPv4Network,
        use_dns: bool,
        use_keepalive: bool,
        server_identity_path: Path,
        client_identity_path: Path,
        wg_conf_path: Path
    ): # pylint: disable=too-many-arguments
    ''' main method '''

    server = ServerIdentity.from_json(server_identity_path.read_text('utf-8'))
    client = WireguardClientConfig(
        vpn_ip=vpn_ip,
        allowed_ips=allowed_ips or server.vpn_network,

        use_vpn_dns=use_dns,
        use_keepalive=use_keepalive
    )

    client.gen_client_keys()

    client_identity_path.write_text(client.create_client_identity(), 'utf-8')
    client_identity_path.chmod(0o600) # chmod 600
    if os.geteuid() == 0:
        os.chown(client_identity_path, uid=0, gid=0) # chown root:root

    wg_conf_path.write_text(client.create_client_config(server), 'utf-8')
    wg_conf_path.chmod(0o600) # chmod 600
    if os.geteuid() == 0:
        os.chown(wg_conf_path, uid=0, gid=0) # chown root:root

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Builds a wireguard client configuration file')
    parser.add_argument(
        'vpn_ip',
        type=ipaddress.IPv4Address,
        help='The IP address within the VPN for the client (e.g. 10.0.0.1).'
    )
    parser.add_argument(
        '--allowed-ips',
        type=ipaddress.IPv4Network,
        required=False,
        help='The IP addresses within the VPN from which to accept traffic in CIDR notation (e.g. 10.0.0.0/24).'
    )
    parser.add_argument(
        '--use-dns',
        action=argparse.BooleanOptionalAction,
        help='Indicate that the VPN designated DNS server should be used in the client configuration. Only works if the server identity has a DNS IP recorded.'
    )
    parser.add_argument(
        '--use-keepalive',
        action=argparse.BooleanOptionalAction,
        help='Indicate that a persistent keepalive should be used in the client configuration.'
    )
    parser.add_argument(
        '--server-identity-path',
        type=Path,
        required=True,
        help='The path to the server identity file.'
    )
    parser.add_argument(
        '--client-identity-path',
        type=Path,
        required=True,
        help='The path to where the client identity file will be written to upon client config generation.'
    )
    parser.add_argument(
        '--wg-conf-path',
        type=Path,
        default=Path('/etc/wireguard/wg0.conf'),
        help='The path to where the wireguard config file will be written to on the local system.'
    )

    args = parser.parse_args()
    main(**args.__dict__)
