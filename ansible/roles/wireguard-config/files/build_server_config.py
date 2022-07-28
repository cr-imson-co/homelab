#!/usr/bin/env python3
''' Builds the wireguard server configuration file '''
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
from typing import List, Union

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

@dataclass
class ClientIdentity:
    ''' Represents the client "identity" for details required by the client when building the Wireguard server configuration. '''

    vpn_ip: ipaddress.IPv4Address
    public_key: str
    preshared_key: str

    @staticmethod
    def from_json(payload: str) -> ClientIdentity:
        ''' Load a client identity from a JSON payload '''
        identity = json.loads(payload)
        identity['vpn_ip'] = ipaddress.IPv4Address(identity['vpn_ip'])

        return ClientIdentity(**identity)

    def to_config_piece(self) -> str:
        ''' Create a wireguard configuration file fragment from the given client identity. '''
        config = f'''
            [Peer]
            PublicKey = {self.public_key}
            PresharedKey = {self.preshared_key}
            AllowedIPs = {str(self.vpn_ip)}/32
        '''

        return textwrap.dedent(config).rstrip('\n')

@dataclass
class WireguardServerConfig:
    ''' Handles the client configuration generation for the Wireguard client. '''

    vpn_endpoint: str
    vpn_port: int

    vpn_network: ipaddress.IPv4Network
    vpn_server_ip: ipaddress.IPv4Address
    dns_ip: Union[ipaddress.IPv4Address, None]

    private_key: str = ''
    public_key: str = ''

    @staticmethod
    def from_json_conf(payload: str) -> WireguardServerConfig:
        ''' todo '''

        config = json.loads(payload)
        config['vpn_network'] = ipaddress.IPv4Network(config['vpn_network'])
        config['vpn_server_ip'] = ipaddress.IPv4Address(config['vpn_server_ip'])

        if config['dns_ip']:
            config['dns_ip'] = ipaddress.IPv4Address(config['dns_ip'])

        return WireguardServerConfig(**config)

    def create_server_config(self, clients: List[ClientIdentity]) -> str:
        ''' Build a complete Wireguard configuration file, given an appropriate server config and list of clients. '''

        config = f'''
            [Interface]
            Address = {self.vpn_server_ip}/{self.vpn_network.prefixlen}
            ListenPort = {self.vpn_port}
            PrivateKey = {self.private_key}
            PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
            PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
        '''

        config = textwrap.dedent(config).lstrip('\n')
        config += '\n'.join([client.to_config_piece() for client in clients])

        return config.rstrip('\n') + '\n'

def main(
        server_config_path: Path,
        client_identities_path: Path,
        wg_conf_path: Path
    ): # pylint: disable=too-many-arguments
    ''' main method '''

    server: WireguardServerConfig = WireguardServerConfig.from_json_conf(server_config_path.read_text('utf-8'))
    if not client_identities_path.is_dir():
        raise ValueError('--client-identities-path must be a directory')

    clients: List[ClientIdentity] = []
    for entry in client_identities_path.iterdir():
        if entry.is_file():
            clients.append(ClientIdentity.from_json(entry.read_text('utf-8')))

    wg_conf_path.write_text(server.create_server_config(clients), 'utf-8')
    wg_conf_path.chmod(0o600) # chmod 600
    if os.geteuid() == 0:
        os.chown(wg_conf_path, uid=0, gid=0) # chown root:root

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Builds a server wireguard configuration file.')
    parser.add_argument(
        '--server-config-path',
        type=Path,
        required=True,
        help='The path to the server configuration file.'
    )
    parser.add_argument(
        '--client-identities-path',
        type=Path,
        required=True,
        help='The directory where client identity files are located.'
    )
    parser.add_argument(
        '--wg-conf-path',
        type=Path,
        default=Path('/etc/wireguard/wg0.conf'),
        help='The path to where the wireguard config file will be written to on the local system.'
    )

    args = parser.parse_args()
    main(**args.__dict__)
