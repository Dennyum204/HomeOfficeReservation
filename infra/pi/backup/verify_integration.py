"""Real PostgreSQL + encrypted local restic transport on disposable native ARM64 CI ONLY."""
import json
import os
from pathlib import Path
import tempfile

from backup import Backup


def verify_integration(trial):
    if os.environ.get('GITHUB_ACTIONS') != 'true' or os.environ.get('RUNNER_ARCH') != 'ARM64':
        raise RuntimeError('Backup integration harness is CI-only; never run against the live Pi')
    binary = os.environ['HO_RESTIC_TEST_BINARY']
    # Retain recovered files until the caller completes authenticated DP recovery checks.
    workspace = Path(tempfile.mkdtemp(prefix='ho012-backup-ci-'))
    workspace.chmod(0o700)
    password = workspace / 'password'
    password.write_text('isolated-ci-restic-password-only')
    password.chmod(0o600)
    config = {'trial': str(trial), 'state': str(workspace / 'state'), 'restic': binary,
              'repository': str(workspace / 'repository'), 'password_file': str(password), 'repository_id': ''}
    backup = Backup(config, local_test=True)
    backup.restic('init', '--repository-version', '2')
    config['repository_id'] = json.loads(backup.restic('cat', 'config'))['id']
    backup.capture()
    snapshot = backup.publish()
    backup.restic('check', '--read-data')
    recovered = backup.restore(snapshot)
    name = 'ho012_restore_restic_ci'
    backup.restore_database(recovered, name)
    try:
        backup.restore_database(recovered, name)
    except RuntimeError:
        pass
    else:
        raise AssertionError('Existing database was not refused')
    sql = backup.dc + ['exec', '-T', 'database', 'psql', '-X', '-qAt', '-U', 'postgres']
    source_members = backup.run(sql + ['-d', 'homeoffice', '-c', 'SELECT count(*) FROM "Members"']).strip()
    restored_members = backup.run(sql + ['-d', name, '-c', 'SELECT count(*) FROM "Members"']).strip()
    assert source_members == restored_members == b'2'
    assert backup.run(backup.dc + ['exec', '-T', 'app', 'bash', '/app/healthcheck.sh']) is not None
    return name, recovered / 'current/trial/private', {
        'transport': 'real encrypted local restic repository on disposable ARM64 CI; NOT external R2',
        'checks': ['capture includes SQL/configuration/PFX/key ring/runtime images', 'source app resumed',
                   'encrypted snapshot upload to local repository', 'download and SHA256 verification',
                   'full repository read', '7 daily/6 monthly retention command',
                   'restore into new PostgreSQL database', 'existing database refused', 'source member count unchanged'],
        'external_destination': 'unconfigured; upload and restore still require authorization and live evidence'}
