"""Protect diagnostic logs from native-test credentials and debugger capabilities."""
import base64
import unittest

from run_ios_integration import LogRedactor


class PrivateDiagnosticsTests(unittest.TestCase):
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
