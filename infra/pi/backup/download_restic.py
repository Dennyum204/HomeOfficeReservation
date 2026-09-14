#!/usr/bin/env python3
"""Fetch a pinned upstream binary outside the Pi; verify archive before extraction."""
import argparse
import bz2
import hashlib
from pathlib import Path
import urllib.request
import zipfile
import io

VERSION = '0.19.1'
ASSETS = {
    'linux_arm64': ('bz2', 'a5f64aaab53d51e311fa3829124c5b703f2d14cf187d8640b6be3b2b49376465'),
    'windows_amd64': ('zip', 'da948ad707ed690426473aaba2046cd61f8f90f6f0e7dab6be0d5796531de67d'),
}


def download(platform, destination):
    extension, expected = ASSETS[platform]
    name = f'restic_{VERSION}_{platform}.{extension}'
    data = urllib.request.urlopen('https://github.com/restic/restic/releases/download/v' + VERSION + '/' + name, timeout=90).read()
    if hashlib.sha256(data).hexdigest() != expected:
        raise ValueError('Upstream archive checksum mismatch')
    if extension == 'bz2':
        binary = bz2.decompress(data)
    else:
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            binary = archive.read(f'restic_{VERSION}_{platform}.exe')
    with Path(destination).open('xb') as output:
        output.write(binary)
    Path(destination).chmod(0o755)
    print('Verified restic ' + VERSION + ' ' + platform + '; executable SHA256=' + hashlib.sha256(binary).hexdigest())


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('platform', choices=ASSETS)
    parser.add_argument('destination', type=Path)
    args = parser.parse_args()
    download(args.platform, args.destination)
