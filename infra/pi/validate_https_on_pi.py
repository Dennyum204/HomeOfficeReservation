#!/usr/bin/env python3
"""Back up the existing trial, temporarily validate the private HTTPS origin, restore local access.

Requires interactive operator sudo. Never contacts Cloudflare or publishes a hostname.
"""
import argparse
import ipaddress
import json
import os
from pathlib import Path
import platform
import hashlib
import subprocess
from prepare_https import CONNECTOR_IMAGE
from verify_https import verify

ROOT = Path('/home/dennyum/ho012-pi-trial')


def main(expected_image):
    if os.geteuid() != 0 or platform.machine() not in ('aarch64', 'arm64'):
        raise RuntimeError('Root and native ARM64 required.')
    if (ROOT / '.ho012-pi-trial').read_bytes() != b'homeoffice-pi-trial\n':
        raise RuntimeError('Existing trial marker mismatch.')
    if (ROOT / 'private/https').exists():
        raise RuntimeError('HTTPS preparation already exists: inspect before repeating; no overwrite.')
    memory = dict(line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(memory['MemAvailable'].split()[0]) < 2 * 1024 * 1024:
        raise RuntimeError('Less than 2 GiB available; postpone this trial.')
    def run(args):
        result = subprocess.run(args, cwd=ROOT, capture_output=True, timeout=300)
        if result.returncode:
            raise RuntimeError('Preparation command failed: ' + args[0] + '; no secret output printed')
        return result.stdout
    names = run(['docker', 'network', 'ls', '-q']).decode().split()
    networks = json.loads(run(['docker', 'network', 'inspect', *names]))
    proposed = ipaddress.ip_network('10.78.18.0/29')
    for network in networks:
        for block in network.get('IPAM', {}).get('Config') or []:
            if block.get('Subnet') and ipaddress.ip_network(block['Subnet']).version == 4:
                if ipaddress.ip_network(block['Subnet']).overlaps(proposed):
                    raise RuntimeError('New connector subnet collides; preserve existing networks.')
    run(['sh', 'trial.sh', 'health'])  # Existing four services, same labelled resources.
    run(['docker', 'pull', '--platform', 'linux/arm64', CONNECTOR_IMAGE])
    meta = json.loads(run(['docker', 'image', 'inspect', CONNECTOR_IMAGE]))[0]
    if meta['Architecture'] != 'arm64' or meta['Id'] != expected_image:
        raise RuntimeError('Connector does not match verified ARM64 CI image; refusing changes.')
    before = set((ROOT / 'private/backups').iterdir())
    run(['sh', 'trial.sh', 'backup'])
    backups = set((ROOT / 'private/backups').iterdir()) - before
    if len(backups) != 1:
        raise RuntimeError('Could not identify the new backup; refusing origin changes.')
    backup = backups.pop()
    # The backup routine covers DB + original application/PFX/key ring. Preserve routing too.
    import shutil
    for name in ['compose.yaml', 'Caddyfile']:
        shutil.copy2(ROOT / name, backup / name)
        with (backup / 'SHA256SUMS').open('a', encoding='utf-8', newline='\n') as sums:
            sums.write(hashlib.sha256((backup / name).read_bytes()).hexdigest() + '  ./' + name + '\n')
    evidence = verify(ROOT)
    run(['sh', 'trial.sh', 'health'])
    evidence['source'] = 'Pi private origin; simulated connector, no Cloudflare connection'
    evidence['original_local_access_restored'] = True
    evidence['backup_path'] = str(backup)
    receipt = ROOT / 'private/https/verification.json'
    receipt.write_text(json.dumps(evidence, indent=2) + '\n', encoding='utf-8', newline='\n')
    print(json.dumps(evidence, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--image-id', required=True)
    args = parser.parse_args()
    if len(args.image_id) != 71 or not args.image_id.startswith('sha256:'):
        parser.error('Use the verified ARM64 image ID from CI, not a mutable tag.')
    main(args.image_id)
