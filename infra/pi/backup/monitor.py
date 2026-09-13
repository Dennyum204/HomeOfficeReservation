#!/usr/bin/env python3
"""Optional empty-body hosted heartbeat; no URLs, payloads or response bodies in logs."""
import argparse
import json
import re
import time
import urllib.request
from pathlib import Path
from backup import private_file, write_json

CONFIG = Path('/etc/homeoffice-backup/monitor.json')
STATE = Path('/var/lib/homeoffice-backup')
URL = re.compile(r'https://hc-ping\.com/[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}')
KINDS = ('daily', 'weekly', 'rehearsal')

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def load(path=CONFIG):
    if not path.exists():
        return None  # Existing backups remain independent of unapproved monitoring.
    config = json.loads(private_file(path).read_text())
    if config.get('enabled') is False:
        return None
    if config.get('enabled') is not True or config.get('recipient_confirmed') is not True:
        raise ValueError('Monitoring approval missing')
    checks = config['checks']
    if set(checks) != set(KINDS) or any(not isinstance(v, str) or not URL.fullmatch(v) for v in checks.values()):
        raise ValueError('Invalid monitoring destinations')
    if len(set(checks.values())) != len(KINDS):
        raise ValueError('Checks must be independent')
    return checks


def send(url, event):
    if not URL.fullmatch(url) or event not in ('start', 'success', 'fail'):
        return False
    endpoint = url + {'start': '/start', 'success': '', 'fail': '/fail'}[event]
    # Do not inherit proxies, attach output, follow redirects, or disable TLS checks.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}), NoRedirect())
    for attempt in range(2):
        try:
            request = urllib.request.Request(endpoint, data=b'', method='POST',
                                            headers={'User-Agent': 'HomeOffice-backup-monitor/1'})
            with opener.open(request, timeout=5) as response:
                if response.status == 200:
                    return True
        except Exception:
            pass  # Exception/response text can contain the secret URL.
        if attempt == 0:
            time.sleep(1)
    return False


def event(checks, kind, signal, state=STATE, transport=send, now=time.time):
    if checks is None:
        return 0
    marker = state / ('monitor-' + kind + '.json')
    if signal == 'start':
        write_json(marker, {'started': now(), 'result': 'running'})
    if signal == 'success' and kind != 'rehearsal':
        started = json.loads(marker.read_text())
        receipt = json.loads((state / ('status.json' if kind == 'daily' else 'full-check.json')).read_text())
        completed = receipt.get('last_success' if kind == 'daily' else 'at', 0)
        if started['result'] != 'start' or receipt.get('result') != 'success' or completed < started['started']:
            raise ValueError('No fresh completed operation; success refused')
    acknowledged = transport(checks[kind], signal)
    write_json(marker, {**(json.loads(marker.read_text()) if marker.exists() else {}),
                        'result': signal, 'acknowledged': acknowledged, 'at': now()})
    return 0 if acknowledged else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('kind', choices=KINDS)
    parser.add_argument('signal', choices=('start', 'success', 'fail'))
    args = parser.parse_args()
    try:
        result = event(load(), args.kind, args.signal)
    except Exception:
        result = 1
    # Only fixed enum values; never include config paths, URLs, exceptions or stdout from backup.
    print('HO012_MONITOR ' + args.kind + ' ' + args.signal + (' OK_OR_DISABLED' if result == 0 else ' FAILED'))
    return result

if __name__ == '__main__':
    raise SystemExit(main())
