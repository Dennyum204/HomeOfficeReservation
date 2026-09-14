#!/usr/bin/env python3
"""Prepare a NEW private trial folder on the workstation; never connect to the Pi."""
import argparse
import json
import os
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import uuid

ROOT = Path(__file__).resolve().parents[2]


def prepare(destination, image):
    destination = Path(destination)
    if not destination.is_absolute() or destination.resolve().is_relative_to(ROOT):
        raise ValueError('Choose an absolute NEW directory outside the repository.')
    if not re.fullmatch(r'homeoffice-pi:ho012-[0-9a-f]{40}', image):
        raise ValueError('Use homeoffice-pi:ho012-<full verified commit SHA>.')
    destination.mkdir(parents=True, exist_ok=False, mode=0o700)
    private = destination / 'private'
    private.mkdir(mode=0o700)
    (private / 'keys').mkdir(mode=0o700)
    def write(name, content):
        path = private / name
        path.write_text(content, encoding='utf-8', newline='\n')
        path.chmod(0o600)
    password, pfx_password = secrets.token_hex(32), secrets.token_hex(32)
    write('postgres-password', secrets.token_hex(32))
    write('database-password', password)
    write('smtp-auth', 'pi-trial:' + password + '\n')
    # Synthetic PKI valid only for this local trial, not public HTTPS or production DP.
    def openssl(*args):
        subprocess.run(['openssl', *args], check=True, capture_output=True,
                       env={**os.environ, 'HO_Pi_PFX_PASSWORD': pfx_password})
    openssl('req', '-x509', '-newkey', 'rsa:3072', '-nodes', '-days', '30', '-subj', '/CN=HO012 Pi trial',
            '-addext', 'subjectAltName=DNS:localhost,DNS:mailpit,IP:10.78.17.2',
            '-addext', 'basicConstraints=critical,CA:TRUE',
            '-addext', 'keyUsage=digitalSignature,keyEncipherment,keyCertSign',
            '-addext', 'extendedKeyUsage=serverAuth',
            '-keyout', str(private / 'server.key'), '-out', str(private / 'server.pem'))
    shutil.copyfile(private / 'server.pem', private / 'ca.pem')
    # Separate RSA key for DP: HTTPS renewal must not strand the encrypted key ring.
    openssl('req', '-x509', '-newkey', 'rsa:3072', '-nodes', '-days', '365', '-subj', '/CN=HO012 Data Protection',
            '-keyout', str(private / 'dp.key'), '-out', str(private / 'dp.pem'))
    openssl('pkcs12', '-export', '-inkey', str(private / 'dp.key'), '-in', str(private / 'dp.pem'),
            '-out', str(private / 'protection.pfx'), '-passout', 'env:HO_Pi_PFX_PASSWORD')
    # Only these just-created temporary plaintext DP intermediates are removed.
    (private / 'dp.key').unlink()
    (private / 'dp.pem').unlink()
    config = {
        'AllowedHosts': 'localhost', 'Hosting': {'PublicOrigin': 'https://localhost:18443', 'KnownProxies': '10.78.17.2'},
        'ConnectionStrings': {'Database': 'Host=database;Database=homeoffice;Username=homeoffice;Maximum Pool Size=10;Password=' + password},
        'DataProtection': {'KeyDirectory': '/var/lib/homeoffice/keys', 'CertificatePath': '/run/config/protection.pfx', 'CertificatePassword': pfx_password},
        'Email': {'Host': 'mailpit', 'Port': 1025, 'From': 'sender@pi.example', 'Username': 'pi-trial', 'Password': password},
        'Notifications': {'WorkerEnabled': True, 'PushProvider': 'Disabled'},
        'Logging': {'LogLevel': {'Default': 'Warning'}}
    }
    write('application.json', json.dumps(config, indent=2) + '\n')
    write('bootstrap.json', json.dumps({'organizationName': 'HO-012 ENSAIO Pi — SINTETICO',
        'email': 'owner@pi.example', 'displayName': 'Titular — ENSAIO Pi'}) + '\n')
    write('CREDENCIAIS.json', json.dumps({name: {'email': name + '@pi.example', 'password': 'Ho9!' + secrets.token_hex(18)}
                                       for name in ['owner', 'manager']}, indent=2) + '\n')
    for path in private.iterdir():
        path.chmod(0o700 if path.is_dir() else 0o600)
    for name in ['compose.yaml', 'Caddyfile', 'trial.sh', 'inventory.sh']:
        (destination / name).write_text(Path(__file__).with_name(name).read_text(encoding='utf-8'), encoding='utf-8', newline='\n')
    (destination / 'init-database.sh').write_text((ROOT / 'infra/pilot/init-database.sh').read_text(encoding='utf-8'), encoding='utf-8', newline='\n')
    tag = image.split(':')[1]
    (destination / '.env').write_text('HO_TRIAL_ID=' + uuid.uuid4().hex + '\nHO_IMAGE=' + image + '\n' +
        'HO_DATABASE_IMAGE=homeoffice-pi-postgres:' + tag + '\n' +
        'HO_EDGE_IMAGE=homeoffice-pi-caddy:' + tag + '\n' +
        'HO_MAIL_IMAGE=homeoffice-pi-mailpit:' + tag + '\n', encoding='utf-8', newline='\n')
    (destination / '.ho012-pi-trial').write_text('homeoffice-pi-trial\n', encoding='utf-8', newline='\n')
    return destination


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--destination', required=True)
    parser.add_argument('--image', required=True)
    args = parser.parse_args()
    prepare(args.destination, args.image)
    print('Private trial prepared. No connection, installation, activation or email sent. Protect the folder with your OS account ACL.')
