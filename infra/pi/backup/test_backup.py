import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from backup import Backup, TAG, PROJECT, FILES, HTTPS_FILES, database_name, manifest, verify_bundle, write_json, status


class SafetyTests(unittest.TestCase):
    def test_database_refuses_source_and_injection(self):
        for value in ['homeoffice', 'postgres', 'ho012_restore_', 'ho012_restore_x;DROP DATABASE homeoffice', 'ho012_restore_' + 'a' * 36]:
            with self.assertRaises(ValueError):
                database_name(value)
        self.assertEqual(database_name('ho012_restore_trial1'), 'ho012_restore_trial1')

    def test_integrity_missing_modified_and_extra_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / 'protection.pfx').write_bytes(b'synthetic encrypted key')
            manifest(root)
            verify_bundle(root)
            (root / 'protection.pfx').write_bytes(b'corrupted')
            with self.assertRaises(ValueError):
                verify_bundle(root)
            (root / 'protection.pfx').unlink()
            with self.assertRaises(ValueError):
                verify_bundle(root)

    def test_manifest_traversal_refused(self):
        with tempfile.TemporaryDirectory() as tmp:
            write_json(Path(tmp) / 'manifest.json', {'sha256': {'../outside': 'x'}})
            with self.assertRaises(ValueError):
                verify_bundle(Path(tmp))

    def test_download_failure_never_prunes(self):
        backup = Backup.__new__(Backup)
        backup.state = Path('/private')
        calls = []
        backup.repository_check = lambda: None
        def restic(*args):
            calls.append(args)
            if args[0] == 'backup':
                return json.dumps({'message_type': 'summary', 'snapshot_id': 'a'*64}).encode()
            return b''
        backup.restic = restic
        backup.restore = lambda *_args, **_kw: (_ for _ in ()).throw(RuntimeError('download failed'))
        with self.assertRaises(RuntimeError):
            backup.publish()
        self.assertNotIn('forget', [x[0] for x in calls])

    def test_failed_status_does_not_hide_old_success_or_staleness(self):
        import time
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            self.assertEqual(status(root), 1)
            write_json(root / 'full-check.json', {'result': 'success', 'at': time.time()})
            for result, last, expected in [('success', time.time(), 0), ('failed', time.time(), 1), ('success', time.time()-37*3600, 1)]:
                write_json(root / 'status.json', {'result': result, 'last_success': last})
                self.assertEqual(status(root), expected)
            write_json(root / 'status.json', {'result': 'success', 'last_success': time.time()})
            write_json(root / 'full-check.json', {'result': 'failed', 'at': time.time()})
            self.assertEqual(status(root), 1)
            write_json(root / 'full-check.json', {'result': 'success', 'at': time.time()-9*86400})
            self.assertEqual(status(root), 1)

    def test_unauthorized_destination_refused_before_command(self):
        c = {'trial': '/home/dennyum/ho012-pi-trial', 'state': '/var/lib/homeoffice-backup',
             'external_authorized': False, 'recovery_kit_confirmed': False}
        with self.assertRaises(ValueError):
            Backup(c)

    def test_capture_always_resumes_after_dump_failure(self):
        # Exercise the real capture cleanup path without touching Docker or any existing app.
        with tempfile.TemporaryDirectory() as tmp:
            b = Backup.__new__(Backup)
            b.state = Path(tmp)
            b.trial = Path(tmp) / 'trial'
            b.dc = ['docker', 'compose']
            b.trial_check = lambda: None
            resumed = []
            b.resume = lambda: resumed.append(True)
            runtime = b.state / 'runtime'; runtime.mkdir()
            write_json(runtime / 'images.json', [{'id': 'id', 'tags': ['tag']}])
            (runtime / 'images.tar').write_bytes(b'fake image'); manifest(runtime)
            def run(args, **_kw):
                if 'config' in args: return b'tag\n'
                if 'inspect' in args: return json.dumps([{'Os':'linux','Architecture':'arm64','Id':'id','RepoTags':['tag']}]).encode()
                if 'ps' in args: return b'app\n'
                if 'pg_dump' in args: raise RuntimeError('dump failure')
                return b''
            b.run = run
            with self.assertRaises(RuntimeError): b.capture()
            self.assertEqual(len(resumed), 2)

    def test_capture_includes_active_https_and_keys_without_changing_source(self):
        with tempfile.TemporaryDirectory() as tmp:
            b = Backup.__new__(Backup)
            b.state = Path(tmp) / 'state'; b.state.mkdir()
            b.trial = Path(tmp) / 'trial'; b.trial.mkdir()
            b.dc = ['docker', 'compose']; b.trial_check = lambda: None; b.resume = lambda: None
            files = FILES + ['private/https/' + p for p in HTTPS_FILES] + ['private/keys/key-test.xml']
            for name in files:
                path = b.trial / name; path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text('synthetic:' + name)
            runtime = b.state / 'runtime'; runtime.mkdir()
            write_json(runtime / 'images.json', [{'id': 'id', 'tags': ['tag']}])
            (runtime / 'images.tar').write_bytes(b'image'); manifest(runtime)
            def run(args, **kw):
                if 'config' in args: return b'tag\n'
                if 'inspect' in args: return json.dumps([{'Os':'linux','Architecture':'arm64','Id':'id','RepoTags':['tag']}]).encode()
                if 'ps' in args: return b'app\n'
                if 'pg_dump' in args: kw['stdout'].write(b'dump')
                return b''
            b.run = run
            b.capture()
            verify_bundle(b.state / 'current')
            for name in files:
                self.assertEqual((b.state / 'current/trial' / name).read_text(), 'synthetic:' + name)
                self.assertEqual((b.trial / name).read_text(), 'synthetic:' + name)


class RealResticTests(unittest.TestCase):
    def test_encrypted_repository_roundtrip_wrong_password_and_wrong_repository(self):
        binary = os.environ.get('HO_RESTIC_TEST_BINARY')
        if not binary:
            self.fail('Set HO_RESTIC_TEST_BINARY to the pinned local binary; do not skip encryption tests')
        with tempfile.TemporaryDirectory(prefix='ho012-restic-test-') as tmp:
            root = Path(tmp); root.chmod(0o700)
            password = root / 'password'; password.write_text('synthetic-password-for-test-only')
            state = root / 'state'; state.mkdir(mode=0o700)
            c = {'trial': str(root / 'unused-trial'), 'state': str(state), 'restic': binary,
                 'repository': str(root / 'repository'), 'password_file': str(password), 'repository_id': ''}
            b = Backup(c, local_test=True)
            b.restic('init', '--repository-version', '2')
            c['repository_id'] = json.loads(b.restic('cat', 'config'))['id']
            for name in ('current', 'runtime'):
                folder = state / name; folder.mkdir(mode=0o700)
                (folder / 'sample').write_bytes(b'HO012_PLAINTEXT_MUST_NOT_APPEAR_IN_REPOSITORY')
                manifest(folder)
            # Linux paths match the production runner. Windows covers crypto separately below.
            if os.name == 'posix':
                snap = b.publish()
                restored = b.restore(snap)
                self.assertEqual((restored / 'current/sample').read_bytes(), (state / 'current/sample').read_bytes())
            else:
                b.restic('backup', '--host', PROJECT, '--tag', TAG, str(state / 'current'))
                b.restic('check', '--read-data')
            for file in (root / 'repository').rglob('*'):
                if file.is_file():
                    self.assertNotIn(b'HO012_PLAINTEXT_MUST_NOT_APPEAR_IN_REPOSITORY', file.read_bytes())
            password.write_text('wrong-key')
            with self.assertRaises(RuntimeError): b.restic('snapshots')
            password.write_text('synthetic-password-for-test-only')
            c['repository_id'] = '0'*64
            with self.assertRaises(ValueError): b.repository_check()
            pack = next(p for p in (root / 'repository/data').rglob('*') if p.is_file())
            # Restic stores packs read-only on Linux. Deliberately corrupt ONLY this
            # disposable test repository; production permissions remain untouched.
            pack.chmod(0o600)
            pack.write_bytes(b'corrupted pack')
            with self.assertRaises(RuntimeError): b.restic('check', '--read-data')


if __name__ == '__main__':
    unittest.main()
