#!/usr/bin/env python3
"""Private Pi backup runner. No automatic repository creation, deployment or source restore."""
import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time

PROJECT = 'homeoffice-pi-trial'
TAG = 'ho012-pi-v1'
VERSION = '0.19.1'
FILES = ['.env', '.ho012-pi-trial', 'compose.yaml', 'Caddyfile', 'init-database.sh', 'trial.sh',
         'private/application.json', 'private/protection.pfx', 'private/ca.pem',
         'private/bootstrap.json', 'private/postgres-password', 'private/database-password',
         'private/server.pem', 'private/server.key', 'private/smtp-auth']
HTTPS_FILES = ['application.json', 'compose.json', 'Caddyfile', 'origin.pem', 'origin.key',
               'route.json', 'blocked-route.json', 'ingress.json', 'tunnel-token']


def digest(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def write_json(path, value):
    temp = path.with_suffix('.tmp')
    temp.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')
    temp.chmod(0o600)
    temp.replace(path)


def private_file(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Required private file missing or symlink')
    if os.name == 'posix' and (path.stat().st_uid != 0 or path.stat().st_mode & 0o077):
        raise ValueError('Operator configuration must be root-owned, mode 600 or 400')
    return path


def manifest(folder):
    files = {}
    for path in sorted(folder.rglob('*')):
        if path.is_symlink():
            raise ValueError('Symlinks are forbidden in recovery bundle')
        if path.is_file() and path.name != 'manifest.json':
            files[path.relative_to(folder).as_posix()] = digest(path)
    write_json(folder / 'manifest.json', {'version': 1, 'sha256': files})


def verify_bundle(folder):
    data = json.loads((folder / 'manifest.json').read_text())
    actual = {p.relative_to(folder).as_posix() for p in folder.rglob('*') if p.is_file() and p.name != 'manifest.json'}
    if actual != set(data['sha256']):
        raise ValueError('Recovery file inventory mismatch')
    for name, expected in data['sha256'].items():
        path = folder / name
        if Path(name).is_absolute() or '..' in Path(name).parts or path.is_symlink() or not path.resolve().is_relative_to(folder.resolve()):
            raise ValueError('Unsafe manifest path')
        if digest(path) != expected:
            raise ValueError('Recovery checksum mismatch')


def database_name(name):
    if not re.fullmatch(r'ho012_restore_[a-z0-9_]{1,35}', name):
        raise ValueError('Use a new ho012_restore_ database name')
    return name


def validate_source(config):
    # This runner targets the prepared trial, not arbitrary connection strings.
    connection = config['ConnectionStrings']['Database']
    fields = [part.split('=', 1) for part in connection.split(';') if '=' in part]
    for key, expected in [('host', 'database'), ('database', 'homeoffice'), ('username', 'homeoffice')]:
        values = [value for name, value in fields if name.strip().lower() == key]
        if values != [expected]:
            raise ValueError('Active configuration points outside the expected source database')
    protection = config['DataProtection']
    if protection['KeyDirectory'] != '/var/lib/homeoffice/keys' or protection['CertificatePath'] != '/run/config/protection.pfx' or not protection['CertificatePassword']:
        raise ValueError('Unexpected Data Protection recovery configuration')


class Backup:
    def __init__(self, config, local_test=False):
        self.c = config
        self.trial = Path(config['trial']).resolve()
        self.state = Path(config['state']).resolve()
        self.test = local_test
        if not local_test:
            if os.name != 'posix' or os.geteuid() != 0:
                raise ValueError('Operator root execution required')
            if self.trial != Path('/home/dennyum/ho012-pi-trial') or self.state != Path('/var/lib/homeoffice-backup'):
                raise ValueError('Unexpected live trial/state path')
            if not config['external_authorized'] or not config['recovery_kit_confirmed']:
                raise ValueError('Destination authorization and independent recovery kit required')
            if not re.fullmatch(r's3:https://[a-f0-9]{32}\.eu\.r2\.cloudflarestorage\.com/homeoffice-pi-backups/restic-v1', config['repository']):
                raise ValueError('Expected explicitly authorized private EU R2 repository')
            private_file(config['password_file'])
            private_file(config['s3_credentials_file'])
        elif not Path(config['repository']).is_absolute():
            raise ValueError('Local tests require an absolute local repository, never cloud')
        self.state.mkdir(mode=0o700, parents=True, exist_ok=True)
        if self.state.is_symlink() or (os.name == 'posix' and self.state.stat().st_mode & 0o077):
            raise ValueError('State directory must be private')
        self.env = {key: value for key, value in os.environ.items() if key in ('PATH', 'HOME', 'SYSTEMROOT', 'TEMP', 'TMP', 'SSL_CERT_FILE')}
        self.env.update({'RESTIC_REPOSITORY': config['repository'],
                    'RESTIC_PASSWORD_FILE': config['password_file'], 'RESTIC_CACHE_DIR': str(self.state / 'cache'),
                    'AWS_DEFAULT_REGION': 'auto', 'GOMAXPROCS': '2', 'GOMEMLIMIT': '256MiB'})
        if not local_test:
            credentials = json.loads(private_file(config['s3_credentials_file']).read_text())
            self.env.update({key: credentials[key] for key in ('AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY')})
        self.dc = ['docker', 'compose', '-p', PROJECT, '-f', str(self.trial / 'compose.yaml')]
        self.active_config = self.trial / 'private/application.json'
        if (self.trial / 'private/https/compose.json').is_file():
            self.dc += ['-f', str(self.trial / 'private/https/compose.json'), '--profile', 'publish']
            self.active_config = self.trial / 'private/https/application.json'

    def run(self, args, **kw):
        # Never echo commands, stdout, stderr or exception strings containing secrets.
        result = subprocess.run(args, stdout=kw.pop('stdout', subprocess.PIPE), stderr=subprocess.PIPE,
                                env=self.env, timeout=kw.pop('timeout', 1800), **kw)
        if result.returncode:
            raise RuntimeError('Subprocess failed; sensitive output suppressed')
        return result.stdout

    def restic(self, *args):
        return self.run([self.c['restic'], '--limit-upload', '2048', '--retry-lock', '30s', *args])

    def repository_check(self):
        version = self.run([self.c['restic'], 'version']).decode()
        if not version.startswith('restic ' + VERSION + ' '):
            raise ValueError('Pinned restic version required')
        info = json.loads(self.restic('cat', 'config'))
        if info['id'] != self.c['repository_id']:
            raise ValueError('Repository identity differs; refusing backup/retention/restore')

    def trial_check(self):
        if (self.trial / '.ho012-pi-trial').read_text().strip() != PROJECT:
            raise ValueError('Trial marker mismatch')
        ids = self.run(self.dc + ['ps', '-aq']).decode().split()
        if not ids:
            raise ValueError('No existing trial services')
        for container in json.loads(self.run(['docker', 'inspect', *ids])):
            labels = container['Config']['Labels']
            if labels['com.docker.compose.project.working_dir'] != str(self.trial):
                raise ValueError('Compose project collision')
            if labels['com.docker.compose.service'] == 'app':
                source = self.active_config
                mounts = [x['Source'] for x in container['Mounts'] if x['Destination'] == '/run/config/application.json']
                if mounts != [str(source)]:
                    raise ValueError('Running app uses a different configuration mount')
                validate_source(json.loads(source.read_text()))
                if 'ASPNETCORE_ENVIRONMENT=Staging' not in container['Config']['Env']:
                    raise ValueError('Unexpected application environment; recovery purpose may differ')
        if shutil.disk_usage(self.state).free < 8 * 1024**3:
            raise ValueError('Less than 8 GiB free for capture and recovery')

    def resume(self):
        marker = self.state / 'resume-app'
        if marker.exists():
            self.run(self.dc + ['start', 'app'], timeout=120)
            for attempt in range(60):
                try:
                    self.run(self.dc + ['exec', '-T', 'app', 'bash', '/app/healthcheck.sh'], timeout=10)
                    break
                except RuntimeError:
                    if attempt == 59:
                        raise
                    time.sleep(2)
            marker.unlink()

    def capture(self):
        self.trial_check()
        self.resume()  # Recover only a prior capture that stopped an originally running app.
        bundle = self.state / 'current'
        if bundle.exists():
            # Fixed private scratch only, never trial data or earlier manual backups.
            shutil.rmtree(bundle)
        bundle.mkdir(mode=0o700)
        images = self.run(self.dc + ['config', '--images']).decode().splitlines()
        metadata = json.loads(self.run(['docker', 'image', 'inspect', *images]))
        if any(x['Os'] != 'linux' or x['Architecture'] != 'arm64' for x in metadata):
            raise ValueError('Recovery images must be native Linux ARM64')
        runtime = self.state / 'runtime'
        runtime.mkdir(mode=0o700, exist_ok=True)
        identity = [{'id': x['Id'], 'tags': x['RepoTags']} for x in metadata]
        recorded = runtime / 'images.json'
        if not recorded.exists() or json.loads(recorded.read_text()) != identity:
            archive = runtime / 'images.tar.partial'
            self.run(['docker', 'save', '-o', str(archive), *images])
            archive.replace(runtime / 'images.tar')
            write_json(recorded, identity)
            manifest(runtime)
        verify_bundle(runtime)
        # Only app/worker paused. PostgreSQL remains online; no source DB switch.
        running = self.run(self.dc + ['ps', '--status', 'running', '--services']).decode().split()
        if 'app' not in running:
            raise ValueError('App not running; refuse to change its lifecycle')
        (self.state / 'resume-app').write_text('capture\n')
        try:
            self.run(self.dc + ['stop', '-t', '30', 'app'], timeout=90)
            with (bundle / 'database.dump').open('xb') as output:
                self.run(self.dc + ['exec', '-T', 'database', 'pg_dump', '-U', 'postgres', '-d', 'homeoffice',
                                    '-Fc', '--no-owner'], stdout=output, timeout=300)
            files = list(FILES)
            if (self.trial / 'private/https').exists():
                files += ['private/https/' + name for name in HTTPS_FILES]
            keys = list((self.trial / 'private/keys').glob('key-*.xml'))
            if not keys:
                raise ValueError('Data Protection key ring missing')
            files += [str(p.relative_to(self.trial)) for p in keys]
            for name in files:
                source = self.trial / name
                if source.is_symlink() or not source.is_file():
                    raise ValueError('Required recovery material missing or symlink')
                destination = bundle / 'trial' / name
                destination.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
                shutil.copy2(source, destination)
            manifest(bundle)
        finally:
            self.resume()
        verify_bundle(bundle)

    def publish(self):
        self.repository_check()
        output = self.restic('backup', '--json', '--host', PROJECT, '--tag', TAG,
                             str(self.state / 'current'), str(self.state / 'runtime'))
        summary = [json.loads(line) for line in output.splitlines() if json.loads(line).get('message_type') == 'summary'][-1]
        snapshot = summary['snapshot_id']
        self.restic('check')
        # Verify actual download + plaintext checksums of every config/key/database file, every run.
        restored = self.restore(snapshot, include_runtime=False)
        shutil.rmtree(restored)
        # One fixed host/tag group; NEVER apply object lifecycle deletion to a restic repository.
        self.restic('forget', '--host', PROJECT, '--tag', TAG, '--group-by', 'host,tags',
                    '--keep-daily', '7', '--keep-weekly', '4', '--keep-monthly', '6', '--prune', '--max-unused', '5%')
        return snapshot

    def restore(self, snapshot, include_runtime=True):
        if not re.fullmatch('[a-f0-9]{64}', snapshot):
            raise ValueError('Restore requires the full explicit snapshot ID')
        self.repository_check()
        info = json.loads(self.restic('snapshots', '--json', snapshot))
        if len(info) != 1 or info[0]['hostname'] != PROJECT or TAG not in info[0].get('tags', []):
            raise ValueError('Wrong snapshot ownership')
        target = self.state / ('restore-' + str(time.time_ns()))
        target.mkdir(mode=0o700)
        for name in ['current', 'runtime'] if include_runtime else ['current']:
            folder = target / name
            self.restic('restore', snapshot + ':' + (self.state / name).as_posix(), '--target', str(folder))
            verify_bundle(folder)
        return target

    def restore_database(self, folder, name):
        name = database_name(name)
        self.trial_check()
        verify_bundle(folder / 'current')
        # CREATE without DROP/clean: duplicate names fail, source stays untouched.
        self.run(self.dc + ['exec', '-T', 'database', 'psql', '-X', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'postgres',
                           '-c', f'CREATE DATABASE "{name}" OWNER homeoffice;'])
        self.run(self.dc + ['exec', '-T', 'database', 'psql', '-X', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'postgres',
                           '-c', f'REVOKE ALL ON DATABASE "{name}" FROM PUBLIC;'])
        with (folder / 'current/database.dump').open('rb') as source:
            self.run(self.dc + ['exec', '-T', 'database', 'pg_restore', '-U', 'postgres', '--role=homeoffice',
                               '-d', name, '--no-owner', '--no-privileges', '--exit-on-error'], stdin=source)


@contextmanager
def lock(state):
    import fcntl
    with (state / 'operation.lock').open('a') as handle:
        fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        yield


def status(state):
    value = json.loads((state / 'status.json').read_text()) if (state / 'status.json').exists() else {}
    age = time.time() - value.get('last_success', 0)
    good = value.get('result') == 'success' and age < 36 * 3600
    full = json.loads((state / 'full-check.json').read_text()) if (state / 'full-check.json').exists() else {}
    full_good = full.get('result') == 'success' and time.time() - full.get('at', 0) < 8 * 86400
    print(json.dumps({'backup_healthy': good, 'last_result': value.get('result', 'never'),
                      'full_read_healthy': full_good,
                      'hours_since_success': round(age / 3600, 1) if value.get('last_success') else None}))
    return 0 if good and full_good else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config', default='/etc/homeoffice-backup/config.json')
    parser.add_argument('action', choices=['init', 'run', 'check-full', 'status', 'resume', 'restore-new'])
    parser.add_argument('--snapshot')
    parser.add_argument('--database')
    args = parser.parse_args()
    os.umask(0o077)
    config = json.loads(private_file(args.config).read_text())
    if args.action == 'status':
        return status(Path(config['state']))
    backup = Backup(config)
    with lock(backup.state):
        if args.action == 'init':
            if config['repository_id'] != 'REPLACE_AFTER_EXPLICIT_INIT':
                raise ValueError('Repository already configured; initialization refused')
            backup.restic('init', '--repository-version', '2')
            print(json.dumps({'repository_id': json.loads(backup.restic('cat', 'config'))['id']}))
            return 0
        if args.action == 'resume':
            backup.resume()
            return 0
        signal.signal(signal.SIGTERM, lambda *_: sys.exit(1))
        receipt = backup.state / 'status.json'
        old = json.loads(receipt.read_text()) if receipt.exists() else {}
        try:
            backup.repository_check()
            if args.action == 'run':
                write_json(receipt, {**old, 'result': 'running', 'started': time.time()})
                backup.capture()
                snapshot = backup.publish()
                write_json(receipt, {'result': 'success', 'last_success': time.time(), 'snapshot': snapshot})
            elif args.action == 'check-full':
                backup.restic('check', '--read-data')
                write_json(backup.state / 'full-check.json', {'result': 'success', 'at': time.time()})
            else:
                database_name(args.database or '')
                target = backup.restore(args.snapshot or '')
                backup.restore_database(target, args.database)
                print('Restored NEW database; source app unchanged. Private recovery directory: ' + str(target))
            print('HO012 backup operation completed: ' + args.action)
            return 0
        except (Exception, SystemExit):
            write_json(receipt, {**old, 'result': 'failed', 'failed_at': time.time(), 'operation': args.action})
            if args.action == 'check-full':
                write_json(backup.state / 'full-check.json', {'result': 'failed', 'at': time.time()})
            print('HO012 backup FAILED; no success claimed. Inspect systemd status; sensitive output suppressed.', file=sys.stderr)
            return 1


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception:
        print('HO012 backup preflight FAILED; check protected configuration and systemd status.', file=sys.stderr)
        raise SystemExit(1) from None
