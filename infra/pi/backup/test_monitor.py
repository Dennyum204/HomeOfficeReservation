import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import urllib.error
import monitor
from backup import write_json

CHECKS = {kind: 'https://hc-ping.com/00000000-0000-0000-0000-' + f'{i:012d}'
          for i, kind in enumerate(monitor.KINDS, 1)}

class ExternalClockSimulation:
    """Synthetic external deadline, not evidence of Healthchecks or email delivery."""
    def __init__(self):
        self.time = 100
        self.states = {}
        self.deadlines = {}
        self.events = []
    def send(self, url, signal):
        self.events.append((url, signal))
        self.states[url] = {'start': 'running', 'success': 'up', 'fail': 'down'}[signal]
        self.deadlines[url] = self.time + 60
        return True
    def advance(self, seconds):
        self.time += seconds
        for url, deadline in self.deadlines.items():
            if self.time > deadline:
                self.states[url] = 'down'

class MonitorTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.state = Path(self.tmp.name)
        self.remote = ExternalClockSimulation()
    def signal(self, kind, signal):
        return monitor.event(CHECKS, kind, signal, self.state, self.remote.send, lambda: self.remote.time)
    def test_disabled_never_transmits(self):
        with patch('monitor.send') as send:
            self.assertEqual(monitor.event(None, 'daily', 'success'), 0)
            send.assert_not_called()
        path = self.state / 'missing'
        self.assertIsNone(monitor.load(path))
    def test_only_fresh_complete_receipt_can_signal_success(self):
        self.signal('daily', 'start')
        for receipt in [{'result': 'running'}, {'result': 'failed', 'last_success': 200},
                        {'result': 'success', 'last_success': 99}]:
            write_json(self.state / 'status.json', receipt)
            with self.assertRaises(ValueError): self.signal('daily', 'success')
        self.assertEqual([x[1] for x in self.remote.events], ['start'])
        write_json(self.state / 'status.json', {'result': 'success', 'last_success': 101})
        self.assertEqual(self.signal('daily', 'success'), 0)
        with self.assertRaises(ValueError): self.signal('daily', 'success')
    def test_daily_weekly_failure_and_recovery_are_independent(self):
        for kind in ('daily', 'weekly'): self.signal(kind, 'start')
        self.signal('weekly', 'fail')
        write_json(self.state / 'status.json', {'result': 'success', 'last_success': 101})
        self.signal('daily', 'success')
        self.assertEqual(self.remote.states[CHECKS['weekly']], 'down')
        self.assertEqual(self.remote.states[CHECKS['daily']], 'up')
        self.signal('weekly', 'start')
        write_json(self.state / 'full-check.json', {'result': 'success', 'at': 101})
        self.signal('weekly', 'success')
        self.assertEqual(self.remote.states[CHECKS['weekly']], 'up')
    def test_rehearsal_failure_absence_and_recovery_never_touch_backup(self):
        self.signal('rehearsal', 'start'); self.signal('rehearsal', 'fail')
        self.assertEqual(self.remote.states[CHECKS['rehearsal']], 'down')
        self.signal('rehearsal', 'success')
        self.assertEqual(self.remote.states[CHECKS['rehearsal']], 'up')
        self.remote.advance(61)  # Virtual external clock; no sleep, Pi stop or live alert.
        self.assertEqual(self.remote.states[CHECKS['rehearsal']], 'down')
        self.signal('rehearsal', 'success')
        self.assertEqual(self.remote.states[CHECKS['rehearsal']], 'up')
        self.assertFalse((self.state / 'status.json').exists())
        self.assertFalse((self.state / 'full-check.json').exists())
    def test_notification_outage_keeps_backup_receipt_and_returns_failure(self):
        self.signal('daily', 'start')
        write_json(self.state / 'status.json', {'result': 'success', 'last_success': 101})
        result = monitor.event(CHECKS, 'daily', 'success', self.state, lambda *_: False)
        self.assertEqual(result, 1)
        self.assertEqual(json.loads((self.state / 'status.json').read_text())['result'], 'success')
    def test_unapproved_duplicate_or_non_https_destinations_refused(self):
        path = self.state / 'config.json'
        for config in [{'enabled': True, 'recipient_confirmed': False, 'checks': CHECKS},
                       {'enabled': True, 'recipient_confirmed': True, 'checks': dict.fromkeys(monitor.KINDS, CHECKS['daily'])},
                       {'enabled': True, 'recipient_confirmed': True, 'checks': {**CHECKS, 'daily': CHECKS['daily']+'?secret=value'}}]:
            write_json(path, config)
            with patch('monitor.private_file', lambda x: x):
                with self.assertRaises(ValueError): monitor.load(path)
    def test_empty_post_no_redirect_and_transport_exceptions_are_suppressed(self):
        calls = []
        class Response:
            status = 200
            def __enter__(self): return self
            def __exit__(self, *_): pass
        class Opener:
            def open(self, req, timeout):
                calls.append((req, timeout)); return Response()
        with patch('monitor.urllib.request.build_opener', return_value=Opener()):
            self.assertTrue(monitor.send(CHECKS['daily'], 'fail'))
        request, timeout = calls[0]
        self.assertEqual(request.data, b''); self.assertEqual(request.method, 'POST')
        self.assertEqual(timeout, 5)
        self.assertIsNone(monitor.NoRedirect().redirect_request(None,None,302,'',{},'https://example.org'))
        output = io.StringIO()
        with contextlib.redirect_stderr(output), contextlib.redirect_stdout(output), patch('monitor.time.sleep'), patch('monitor.urllib.request.build_opener', side_effect=ValueError('private-url')):
            # Construction errors are sanitized by main, not printed or rethrown to journal.
            with patch('monitor.load', return_value=CHECKS), patch('monitor.event', side_effect=ValueError('private-url')), patch('sys.argv',['monitor.py','daily','fail']):
                self.assertEqual(monitor.main(), 1)
        self.assertNotIn('private-url', output.getvalue())
    def test_network_failure_is_bounded_and_never_prints_secret(self):
        from unittest.mock import Mock
        opener = Mock()
        opener.open.side_effect = urllib.error.URLError(CHECKS['daily'])
        output = io.StringIO()
        with contextlib.redirect_stderr(output), contextlib.redirect_stdout(output), patch('monitor.time.sleep'), patch('monitor.urllib.request.build_opener', return_value=opener):
            self.assertFalse(monitor.send(CHECKS['daily'], 'success'))
        self.assertEqual(opener.open.call_count, 2)
        self.assertEqual(output.getvalue(), '')

    def test_weekly_runner_failure_preserves_daily_receipt(self):
        from unittest.mock import Mock
        import backup
        config = self.state/'config.json'
        write_json(config, {'state': str(self.state)})
        daily = {'result': 'success', 'last_success': 100, 'snapshot': 'synthetic'}
        write_json(self.state/'status.json', daily)
        runner = Mock(state=self.state)
        runner.repository_check.side_effect = RuntimeError('private output')
        with patch('backup.private_file', lambda x: Path(x)), patch('backup.Backup', return_value=runner), patch('backup.lock', lambda _: contextlib.nullcontext()), patch('backup.signal.signal'), patch('sys.argv',['backup.py','--config',str(config),'check-full']), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(backup.main(), 1)
        self.assertEqual(json.loads((self.state/'status.json').read_text()),daily)
        self.assertEqual(json.loads((self.state/'full-check.json').read_text())['result'],'failed')

    def test_success_hook_follows_mandatory_runner_and_failure_is_separate(self):
        base = Path(__file__).parent
        for filename, kind in [('homeoffice-backup.service','daily'),('homeoffice-backup-check.service','weekly')]:
            unit = (base / filename).read_text()
            self.assertIn(f'ExecStartPre=-/usr/bin/python3 /opt/homeoffice-backup/monitor.py {kind} start', unit)
            self.assertIn(f'ExecStartPost=/usr/bin/python3 /opt/homeoffice-backup/monitor.py {kind} success', unit)
            self.assertIn(f'homeoffice-backup-monitor-failure@{kind}.service', unit)
        self.assertNotIn('OnFailure=',(base/'homeoffice-backup-monitor-failure@.service').read_text())

if __name__ == '__main__': unittest.main()
