"""Protect diagnostic logs from native-test credentials and debugger capabilities."""
import base64
import unittest
from unittest.mock import Mock, patch

from run_ios_integration import LogRedactor, service_uri, streamed


class PrivateDiagnosticsTests(unittest.TestCase):
    def test_elapsed_log_drain_does_not_reclassify_an_exited_successful_process(self):
        process = Mock()
        process.poll.return_value = 0
        process.wait.return_value = 0
        process.stdout = []
        # Deterministically reproduce the timer firing after command exit, while
        # Python is still draining its output. This is a lifecycle simulation.
        def timer_after_exit(duration, callback):
            timer = Mock()
            timer.start.side_effect = callback
            return timer
        with patch("run_ios_integration.subprocess.Popen") as popen, \
             patch("run_ios_integration.threading.Timer", side_effect=timer_after_exit):
            popen.return_value.__enter__.return_value = process
            streamed(["synthetic-command"], ".", LogRedactor({}), 1)

    def test_an_active_command_past_its_deadline_fails_even_if_shutdown_returns_zero(self):
        process = Mock(pid=1234)
        process.poll.return_value = None
        process.wait.return_value = 0
        process.stdout = []
        def timer_while_running(duration, callback):
            timer = Mock()
            timer.start.side_effect = callback
            return timer
        with patch("run_ios_integration.subprocess.Popen") as popen, \
             patch("run_ios_integration.threading.Timer", side_effect=timer_while_running), \
             patch("run_ios_integration.os.killpg", create=True) as terminate:
            popen.return_value.__enter__.return_value = process
            with self.assertRaises(RuntimeError):
                streamed(["synthetic-command"], ".", LogRedactor({}), 1)
            terminate.assert_called_once()

    def test_driver_address_requires_a_loopback_vm_service_announcement(self):
        self.assertEqual("http://127.0.0.1:1234/capability=/",
            service_uri("The Dart VM service is listening on http://127.0.0.1:1234/capability=/"))
        self.assertIsNone(service_uri("API URL http://127.0.0.1:5080/"))
        self.assertIsNone(service_uri("The Dart VM service is listening on https://example.invalid/"))

    def test_credentials_are_removed_in_build_and_error_formats(self):
        value = "Synthetic9!local-only"
        redactor = LogRedactor({"TEST_PASSWORD": value})
        encoded = base64.b64encode(("TEST_PASSWORD=" + value).encode()).decode()
        for source in (f"-DTEST_PASSWORD={value}", f"DART_DEFINES={encoded}",
                       f"compiler argument {encoded}", f"Unexpected widget text: {value}"):
            result = redactor.clean(source)
            self.assertNotIn(value, result)
            self.assertNotIn(encoded, result)

    def test_unknown_tokens_and_debugger_urls_are_not_published(self):
        redactor = LogRedactor({})
        for source in ('{"accessToken":"opaque-ticket"}', 'Authorization: Bearer opaque-ticket',
                       'refresh_token=opaque-ticket'):
            self.assertNotIn("opaque-ticket", redactor.clean(source))
        result = redactor.clean("VM connected at http://127.0.0.1:1234/private-capability=/ws")
        self.assertNotIn("private-capability", result)
        self.assertIn("127.0.0.1:1234", result)

    def test_install_launch_and_test_failures_remain_visible(self):
        redactor = LogRedactor({})
        for line in ("executing: xcrun simctl install simulator Runner.app\n",
                     "executing: xcrun simctl launch simulator dev.homeoffice.homeofficeMobile\n",
                     "Expected: one matching widget; Actual: zero\n", "All tests passed!\n"):
            self.assertEqual(line, redactor.clean(line))


if __name__ == "__main__":
    unittest.main()
