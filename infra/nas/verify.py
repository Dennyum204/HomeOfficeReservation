#!/usr/bin/env python3
"""Exercise the exact NAS stack on a disposable Linux CI host. This is NOT NAS evidence."""
from concurrent.futures import ThreadPoolExecutor
from datetime import date, timedelta
import hashlib
import http.cookiejar
import json
import os
from pathlib import Path
import shutil
import ssl
import subprocess
import tempfile
import time
import traceback
import urllib.error
import urllib.request
import uuid
from prepare import prepare, ROOT

STAGE = 'initialize'


def main():
    global STAGE
    if os.name != 'posix' or os.geteuid() != 0:
        raise RuntimeError('Use an isolated Linux CI runner with Docker, as root.')
    sha = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip()
    image = 'homeoffice:ho012-' + sha
    # Build on the runner, never on the NAS. Versions and lockfiles are shared with core CI.
    subprocess.run(['docker', 'build', '--platform', 'linux/amd64', '-f', 'infra/pilot/Dockerfile', '-t', image, '.'], cwd=ROOT, check=True)
    images = [image]
    for name, upstream in [('postgres', 'postgres:18.6-bookworm'), ('caddy', 'caddy:2.11.4-alpine'), ('mailpit', 'axllent/mailpit:v1.31.1')]:
        tag = 'homeoffice-nas-' + name + ':ho012-' + sha
        subprocess.run(['docker', 'pull', '--platform', 'linux/amd64', upstream], check=True)
        subprocess.run(['docker', 'tag', upstream, tag], check=True)
        images.append(tag)
    with tempfile.TemporaryDirectory(prefix='ho012-nas-ci-') as temporary:
        folder = prepare(Path(temporary) / 'trial', image)
        private = folder / 'private'
        credentials = json.loads((private / 'CREDENCIAIS.json').read_text())
        def trial(*args, ok=True):
            result = subprocess.run(['sh', str(folder / 'trial.sh'), *args], cwd=folder, capture_output=True, timeout=300)
            if ok and result.returncode:
                (private / 'operation-error.log').write_bytes(result.stdout + result.stderr)
                raise RuntimeError('Trial operation failed: ' + args[0] + '; private diagnostic retained only on runner.')
            return result
        def dc(*args):
            return subprocess.check_output(['docker', 'compose', '-p', 'homeoffice-nas-trial', '-f', str(folder / 'compose.yaml'), *args], cwd=folder, stderr=subprocess.DEVNULL)
        context = ssl.create_default_context(cafile=str(private / 'ca.pem'))
        def client():
            return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()), urllib.request.HTTPSHandler(context=context))
        owner, manager = client(), client()
        def request(browser, path, body=None, method=None, expected=200, csrf=False):
            headers = {'Host': 'localhost:18443', 'Content-Type': 'application/json'}
            if csrf:
                headers['X-CSRF-TOKEN'] = request(browser, '/api/v1/auth/csrf')['requestToken']
            if body is not None:
                headers['Idempotency-Key'] = str(uuid.uuid4())
            req = urllib.request.Request('https://10.78.16.2' + path,
                None if body is None else json.dumps(body).encode(), headers, method=method)
            try:
                response = browser.open(req, timeout=30)
            except urllib.error.HTTPError as error:
                response = error
            data = response.read()
            if response.status != expected:
                raise RuntimeError(f'Expected HTTP {expected}; got {response.status}. No response payload logged.')
            return json.loads(data) if data and 'application/json' in response.headers.get('Content-Type', '') else data
        def activate(name, browser):
            email = credentials[name]['email']
            for _ in range(60):
                messages = json.load(urllib.request.urlopen('http://10.78.16.3:8025/api/v1/messages'))
                match = next((m for m in messages['messages'] if any(t['Address'] == email for t in m['To'])), None)
                if match:
                    message = json.load(urllib.request.urlopen('http://10.78.16.3:8025/api/v1/message/' + match['ID']))
                    code = message['Text'].replace('\r\n', '\n').split('\n\n')[1].strip()
                    request(browser, '/api/v1/auth/activation/complete', {**credentials[name], 'code': code}, expected=204)
                    return
                time.sleep(1)
            raise RuntimeError('Captured activation delivery timed out.')
        def sql(query, database='homeoffice'):
            return dc('exec', '-T', 'database', 'psql', '-X', '-qAt', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', database, '-c', query).decode().strip()
        try:
            STAGE = 'compose startup and migration'
            trial('validate')
            trial('start')
            assert sql('SELECT count(*) FROM "Members"') == '0'
            trial('health')
            for route in ['/', '/calendar', '/requests', '/administration', '/settings']:
                assert b'<div id="root">' in request(owner, route)
            request(owner, '/api/v1/me', expected=401)
            for route in ['/health/ready', '/health/live', '/openapi/v1.json']:
                request(owner, route, expected=404)
            STAGE = 'owner bootstrap, captured invitations, two identities'
            trial('bootstrap'); trial('bootstrap')
            assert sql('SELECT count(*) FROM "Members"') == '1'
            activate('owner', owner)
            request(owner, '/api/v1/auth/web/login', credentials['owner'], csrf=True, expected=204)
            owner_profile = request(owner, '/api/v1/me')
            assert owner_profile['isEmployee'] and owner_profile['isAccountAdministrator']
            invite = {'email': credentials['manager']['email'], 'displayName': 'Chefia — ENSAIO NAS',
                      'isEmployee': False, 'isManager': True, 'isAccountAdministrator': False}
            for _ in range(2):
                request(owner, '/api/v1/admin/members', invite, csrf=True, expected=204)
            assert sql('SELECT count(*) FROM "Members"') == '2'
            activate('manager', manager)
            request(manager, '/api/v1/auth/web/login', credentials['manager'], csrf=True, expected=204)
            manager_profile = request(manager, '/api/v1/me')
            request(owner, f'/api/v1/admin/members/{owner_profile["memberId"]}/manager',
                    {'managerId': manager_profile['memberId']}, method='PUT', csrf=True, expected=204)
            STAGE = 'owner submission, distinct manager approval and durable inbox'
            day = (date.today() + timedelta(days=30)).isoformat()
            base = '/api/v1/planning/' + owner_profile['memberId']
            draft = request(owner, base + '/requests', {'expectedCalendarVersion': 0, 'expectedRequestVersion': None,
                'parentRevisionId': None, 'note': 'HO012 isolated runner trial',
                'days': [{'localDate': day, 'location': 'RemotePortugal', 'availability': 'Working'}]}, csrf=True)
            detail_url = base + '/requests/' + draft['contextId']
            submitted = request(owner, detail_url + '/submit', {'expectedCalendarVersion': draft['calendarVersion'],
                                'expectedRequestVersion': draft['version']}, csrf=True)
            detail = request(manager, detail_url)
            decision = {'expectedCalendarVersion': submitted['calendarVersion'], 'expectedRequestVersion': submitted['version'],
                        'days': [{'dayId': d['id'], 'expectedVersion': d['version']} for d in detail['days']], 'approve': True, 'reason': None}
            request(owner, detail_url + '/decide', decision, csrf=True, expected=403)
            request(manager, detail_url + '/decide', decision, csrf=True)
            assert request(owner, detail_url)['days'][0]['decision'] == 'Approved'
            for _ in range(60):
                if int(sql('SELECT count(*) FROM "InboxNotification"')) >= 2:
                    break
                time.sleep(1)
            else:
                raise RuntimeError('Durable inbox did not catch up.')
            # Short concurrency smoke, not a NAS capacity/load test or an SLA.
            STAGE = 'two-user read latency and resource constraints'
            def reads(browser):
                times = []
                for _ in range(10):
                    started = time.monotonic()
                    request(browser, detail_url)
                    times.append(round((time.monotonic() - started) * 1000, 1))
                return times
            with ThreadPoolExecutor(max_workers=2) as pool:
                samples = list(pool.map(reads, [owner, manager]))
            metrics = trial('metrics').stdout.decode()
            containers = json.loads(subprocess.check_output(['docker', 'inspect', *dc('ps', '-q').decode().split()]))
            for container in containers:
                assert not container['HostConfig']['PortBindings'], 'No host port publication allowed'
                assert not container['State']['OOMKilled']
                assert container['HostConfig']['Memory'] > 0
                assert container['HostConfig']['MemorySwap'] == container['HostConfig']['Memory']
            STAGE = 'restart, new database restore and preserved encrypted keys'
            keys = list((private / 'keys').glob('key-*.xml'))
            assert keys and all('encryptedSecret' in p.read_text() for p in keys)
            trial('restart')
            assert request(owner, '/api/v1/me')['memberId'] == owner_profile['memberId']
            assert request(manager, detail_url)['days'][0]['decision'] == 'Approved'
            trial('backup')
            backup = next((private / 'backups').iterdir())
            restored = 'ho012_restore_ci'
            trial('restore-new', str(backup), restored)
            assert trial('restore-new', str(backup), restored, ok=False).returncode != 0
            assert sql('SELECT count(*) FROM "Members"', restored) == '2'
            config = json.loads((private / 'application.json').read_text())
            config['ConnectionStrings']['Database'] = config['ConnectionStrings']['Database'].replace('Database=homeoffice;', 'Database=' + restored + ';')
            dc('stop', 'app')
            (private / 'application.json').write_text(json.dumps(config))
            # Recover the actual protected key material as well as the database, only inside this disposable directory.
            shutil.rmtree(private / 'keys')
            shutil.copytree(backup / 'keys', private / 'keys')
            shutil.copyfile(backup / 'protection.pfx', private / 'protection.pfx')
            for path in [private / 'keys', * (private / 'keys').rglob('*'), private / 'protection.pfx']:
                os.chown(path, 1654, 1654)
            dc('start', 'app')
            trial('health')
            assert request(owner, '/api/v1/me')['memberId'] == owner_profile['memberId']
            assert request(manager, detail_url)['days'][0]['decision'] == 'Approved'
            evidence = {'commit': sha, 'environment': 'disposable ubuntu-24.04 CI, NOT Synology NAS',
                'architecture': 'linux/amd64', 'stack': 'four containers; 896 MiB total hard limits; no host ports',
                'checks': ['startup', 'explicit migration', 'no automatic accounts', 'idempotent dual-role owner bootstrap',
                    'captured SMTP STARTTLS', 'invitation replay', 'two activations', 'manager association', 'submission',
                    'self-approval refused', 'manager approval', 'durable inbox', 'two concurrent readers', 'no OOM',
                    'restart preserves session and plan', 'new database restore', 'existing target refused', 'restored keys/session/plan'],
                'read_latency_ms_runner_only': samples, 'nas_installation': 'not performed', 'nas_capacity': 'unmeasured',
                'email': 'captured only; external relay absent', 'push': 'Disabled', 'off_nas_backup': 'not configured'}
            (ROOT / 'ho012-nas-evidence.json').write_text(json.dumps(evidence, indent=2) + '\n')
            (ROOT / 'ho012-nas-runner-metrics.txt').write_text(metrics)
            print(json.dumps(evidence))
        finally:
            # This fixed project exists only on this disposable runner; never invoke this harness on the user's NAS.
            dc('down', '--volumes')
    STAGE = 'image archive export'
    output = ROOT / 'ho012-nas-images'
    output.mkdir(exist_ok=False)
    archive = output / 'images.tar'
    subprocess.run(['docker', 'save', '-o', str(archive), *images], check=True)
    metadata = json.loads(subprocess.check_output(['docker', 'image', 'inspect', *images]))
    assert all(x['Architecture'] == 'amd64' and x['Os'] == 'linux' for x in metadata)
    manifest = {'commit': sha, 'archive_sha256': hashlib.file_digest(archive.open('rb'), 'sha256').hexdigest(),
                'archive_bytes': archive.stat().st_size,
                'images': [{'id': x['Id'], 'tags': x['RepoTags'], 'digests': x['RepoDigests'], 'size': x['Size'],
                            'os': x['Os'], 'architecture': x['Architecture']} for x in metadata]}
    (output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (output / 'SHA256SUMS').write_text(manifest['archive_sha256'] + '  images.tar\n')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print('NAS preparation CI failed at ' + STAGE + ': ' + type(error).__name__)
        for frame in traceback.extract_tb(error.__traceback__):
            print(Path(frame.filename).name + ':' + str(frame.lineno) + ' in ' + frame.name)
        if isinstance(error, RuntimeError):
            print(str(error))
        raise SystemExit(1) from None
