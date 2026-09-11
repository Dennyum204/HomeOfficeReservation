"""Regression: Windows-generated bundles must remain valid Linux input."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from prepare import prepare


class PrepareTests(unittest.TestCase):
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


if __name__ == '__main__':
    unittest.main()
