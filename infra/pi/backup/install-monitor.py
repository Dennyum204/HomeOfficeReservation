#!/usr/bin/env python3
"""Explicit post-approval operator upgrade. Never starts a backup or sends a ping."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time
from monitor import load

BASE = Path('/opt/homeoffice-backup')
UNITS = Path('/etc/systemd/system')
TIMERS = ['homeoffice-backup.timer', 'homeoffice-backup-check.timer']
SERVICES = ['homeoffice-backup.service', 'homeoffice-backup-check.service']

def command(*args):
    return subprocess.check_output(args, stderr=subprocess.DEVNULL, text=True).strip()

def main():
    if os.geteuid() != 0 or load() is None:
        raise ValueError('Root and approved private monitoring configuration required')
    source = Path(__file__).resolve().parent
    baseline = json.loads((source/'monitor-upgrade-baseline.json').read_text())
    targets = {name: (BASE if name.endswith('.py') else UNITS)/name for name in baseline}
    for name, target in targets.items():
        if target.is_symlink() or hashlib.sha256(target.read_bytes()).hexdigest() != baseline[name]:
            raise ValueError('Unknown installed revision; no overwrite')
    additions = {'monitor.py': BASE/'monitor.py',
                 'homeoffice-backup-monitor-failure@.service': UNITS/'homeoffice-backup-monitor-failure@.service'}
    if any(target.exists() or target.is_symlink() for target in additions.values()):
        raise ValueError('Existing monitoring installation; inspect, do not overwrite')
    active = [unit for unit in TIMERS if command('systemctl','show',unit,'--property=ActiveState','--value') == 'active']
    recovery = Path('/var/lib/homeoffice-backup')/('monitor-upgrade-'+str(time.time_ns()))
    recovery.mkdir(mode=0o700)
    for name, target in targets.items(): shutil.copy2(target,recovery/name)
    (recovery/'README.txt').write_text('Rollback: stop both timers; wait for any backup/check to finish; copy backup.py to /opt/homeoffice-backup and the two service files to /etc/systemd/system; systemctl daemon-reload; start only previously active timers. Keep monitor.json private; no database or repository changes.\n')
    changed = False
    try:
        subprocess.run(['systemctl','stop',*TIMERS],check=True,stdout=subprocess.DEVNULL)
        if any(command('systemctl','show',unit,'--property=ActiveState','--value') in ('active','activating','deactivating') for unit in SERVICES):
            raise ValueError('Backup/check in progress; upgrade refused')
        changed = True
        for name, target in {**targets, **additions}.items():
            temp = target.with_suffix(target.suffix+'.ho012-new')
            with temp.open('xb') as stream: stream.write((source/name).read_bytes())
            temp.chmod(0o600 if name.endswith('.py') else 0o644)
            temp.replace(target)
        subprocess.run(['systemctl','daemon-reload'],check=True)
        subprocess.run(['systemd-analyze','verify',*[str(UNITS/unit) for unit in SERVICES]],check=True)
    except Exception:
        if changed:
            for name, target in targets.items(): shutil.copy2(recovery/name,target)
            # New monitoring files are harmless with original units; preserve for diagnosis.
            subprocess.run(['systemctl','daemon-reload'],check=True)
        raise
    finally:
        if active: subprocess.run(['systemctl','start',*active],check=True)
    print('Monitoring hooks installed; timers preserved. No manual backup or ping executed. Recovery: '+str(recovery))

if __name__ == '__main__':
    os.umask(0o077)
    try: main()
    except Exception:
        print('Monitoring upgrade failed; inspect protected state. Secrets withheld.')
        raise SystemExit(1) from None
