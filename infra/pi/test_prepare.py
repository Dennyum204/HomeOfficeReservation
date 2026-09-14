"""Regression: Windows-generated bundles must remain valid Linux input."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from prepare import prepare
from prepare_https import prepare_https, validate_connector, CONNECTOR_IMAGE, CONNECTOR_DIGEST
import json


class PrepareTests(unittest.TestCase):
    def test_registry_identity_across_classic_and_containerd_stores(self):
        for image_id in ['sha256:' + 'a' * 64, CONNECTOR_DIGEST]:
            validate_connector({'Id': image_id, 'Architecture': 'arm64', 'Os': 'linux',
                                'RepoDigests': [CONNECTOR_IMAGE]})
        valid = {'Id': CONNECTOR_DIGEST, 'Architecture': 'arm64', 'Os': 'linux',
                 'RepoDigests': [CONNECTOR_IMAGE]}
        for replacement in [{'RepoDigests': []}, {'RepoDigests': None},
                            {'RepoDigests': ['other/repository@' + CONNECTOR_DIGEST]},
                            {'RepoDigests': ['cloudflare/cloudflared@sha256:' + '0' * 64]},
                            {'Architecture': 'amd64'}, {'Os': 'windows'}]:
            with self.subTest(replacement=replacement), self.assertRaises(RuntimeError):
                validate_connector({**valid, **replacement})

    def test_windows_default_newlines_do_not_contaminate_linux_bundle(self):
        original_write = Path.write_text

        def windows_write(path, data, encoding=None, errors=None, newline=None):
            # Reproduce Windows's default text translation even on the Linux CI runner.
            return original_write(path, data, encoding=encoding, errors=errors,
                                  newline='\r\n' if newline is None else newline)

        with tempfile.TemporaryDirectory(prefix='ho012-newlines-') as temporary:
            destination = Path(temporary) / 'trial'
            with patch.object(Path, 'write_text', windows_write):
                prepare(destination, 'homeoffice-pi:ho012-' + 'a' * 40)
            for name in ['.env', '.ho012-pi-trial', 'trial.sh', 'inventory.sh',
                         'init-database.sh', 'compose.yaml', 'Caddyfile']:
                data = (destination / name).read_bytes()
                self.assertNotIn(b'\r', data, name)
                self.assertFalse(data.startswith(b'\xef\xbb\xbf'), name)
            self.assertEqual((destination / '.ho012-pi-trial').read_bytes(),
                             b'homeoffice-pi-trial\n')
            previous = (destination / '.env').read_bytes()
            with self.assertRaises(FileExistsError):
                prepare(destination, 'homeoffice-pi:ho012-' + 'b' * 40)
            self.assertEqual((destination / '.env').read_bytes(), previous)

    def test_https_staging_preserves_source_secrets_and_refuses_overwrite(self):
        with tempfile.TemporaryDirectory(prefix='ho012-https-') as temporary:
            folder = prepare(Path(temporary) / 'trial', 'homeoffice-pi:ho012-' + 'a' * 40)
            before = {p.relative_to(folder).as_posix(): p.read_bytes() for p in folder.rglob('*') if p.is_file()}
            target = prepare_https(folder)
            for name, value in before.items():
                self.assertEqual((folder / name).read_bytes(), value)
            self.assertFalse((target / 'tunnel-token').exists())
            staged = json.loads((target / 'application.json').read_text(encoding='utf-8'))
            original = json.loads(before['private/application.json'])
            for key in original.keys() - {'Hosting', 'AllowedHosts'}:
                self.assertEqual(staged[key], original[key])
            for path in target.iterdir():
                self.assertNotIn(b'\r', path.read_bytes())
                self.assertFalse(path.read_bytes().startswith(b'\xef\xbb\xbf'))
            with self.assertRaises(FileExistsError):
                prepare_https(folder)


if __name__ == '__main__':
    unittest.main()
