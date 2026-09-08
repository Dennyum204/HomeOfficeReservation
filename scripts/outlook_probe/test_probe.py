"""Synthetic tests only. No browser, account, token endpoint or live Graph calls."""
import copy
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch
from urllib.parse import parse_qs, quote, urlencode, urlsplit
from datetime import date, timedelta

import probe

CONFIG = {"tenant_id": "11111111-1111-4111-8111-111111111111",
          "client_id": "22222222-2222-4222-8222-222222222222",
          "expected_object_id": "33333333-3333-4333-8333-333333333333",
          "mailbox_type": "organizational", "dedicated_test_mailbox": True,
          "consent_confirmed": True, "year": 2026}


class FakeGraph:
    """Models CRUD, recurrence expansion, change history and opaque pagination."""
    def __init__(self):
        self.events, self.changes, self.pages, self.calls = {}, [], {}, []
        self.next_id = 0
        self.next_page = 0

    def record(self, event, deleted=False):
        row = copy.deepcopy(event)
        if deleted:
            row = {"id": event["id"], "@removed": {"reason": "deleted"}, "start": event["start"]}
        self.changes.append(row)

    def page(self, rows, cursor):
        if len(rows) <= 2:
            return {"value": rows, "@odata.deltaLink": cursor}
        self.next_page += 1
        following = probe.GRAPH + "/me/calendarView/delta?" + urlencode({"opaque": "a+/=" + str(self.next_page)})
        self.pages[following] = (rows[2:], cursor)
        return {"value": rows[:2], "@odata.nextLink": following}

    def request(self, method, url, payload=None, zone=None, etag=None, missing_ok=False):
        self.calls.append((method, url, payload))
        p, query = urlsplit(url), parse_qs(urlsplit(url).query)
        if url in self.pages:
            return self.page(*self.pages.pop(url))
        if p.path.endswith("/calendarView/delta"):
            month = int(query.get("month", [query.get("startDateTime", ["2026-03"])[0][5:7]])[0])
            since = int(query.get("since", [0])[0])
            rows = [copy.deepcopy(e) for e in self.changes[since:] if int(e["start"]["dateTime"][5:7]) == month]
            # Real delta responses can contain unrelated private data; it must be discarded.
            rows.insert(0, {"id": "unrelated", "subject": "PRIVATE_SYNTHETIC_CANARY",
                            "body": {"content": "NEVER_LOG_THIS"}})
            cursor = probe.GRAPH + "/me/calendarView/delta?" + urlencode({"since": len(self.changes), "month": month})
            return self.page(rows, cursor)
        if method == "POST":
            assert p.path == "/v1.0/me/events"
            self.next_id += 1
            event = copy.deepcopy(payload)
            event.update({"id": "own-" + str(self.next_id), "@odata.etag": 'W/"1"',
                          "type": "seriesMaster" if "recurrence" in event else "singleInstance"})
            self.events[event["id"]] = event
            if "recurrence" in event:
                for n in range(3):
                    occurrence = copy.deepcopy(event)
                    occurrence.update({"id": event["id"] + "-occ-" + str(n), "type": "occurrence",
                                       "seriesMasterId": event["id"]})
                    for key in ("start", "end"):
                        d = date.fromisoformat(event[key]["dateTime"][:10]) + timedelta(days=n)
                        occurrence[key]["dateTime"] = d.isoformat() + "T00:00:00"
                    self.events[occurrence["id"]] = occurrence
                    self.record(occurrence)
            else:
                self.record(event)
            return copy.deepcopy(event)
        if p.path == "/v1.0/me/events":
            marker = query["$filter"][0].split("ep/value eq '")[1].split("'")[0]
            return {"value": [copy.deepcopy(e) for e in self.events.values()
                              if e["type"] != "occurrence" and any(
                                  x["value"] == marker for x in e.get("singleValueExtendedProperties", []))]}
        identifier = p.path.split("/")[4]
        if p.path.endswith("/instances"):
            return {"value": [copy.deepcopy(e) for e in self.events.values() if e.get("seriesMasterId") == identifier]}
        if identifier not in self.events:
            if missing_ok:
                return None
            raise probe.ProbeError("graph_http_404")
        event = self.events[identifier]
        if method == "GET":
            return copy.deepcopy(event)
        assert etag == event["@odata.etag"]
        if method == "PATCH":
            event.update(payload)
            self.record(event)
            return copy.deepcopy(event)
        assert method == "DELETE"
        for e in list(self.events.values()):
            if e["id"] == identifier or e.get("seriesMasterId") == identifier:
                self.record(e, deleted=True)
                del self.events[e["id"]]


class ProbeTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.state = Path(self.temporary.name) / "state.json"
        self.journal = probe.Journal(self.state, CONFIG)
        self.graph = FakeGraph()
        self.owner = probe.OwnedEvents(self.graph, self.journal)

    def test_dst_and_no_invitations(self):
        fixtures = probe.fixtures(2026)
        self.assertEqual(len(fixtures), 6)
        self.assertEqual([probe.utc_duration(f) for f in fixtures if not f["recurring"]], [23, 25, 23, 25])
        for fixture in fixtures:
            body = probe.event_body(fixture, "marker", "transaction")
            self.assertEqual(body["attendees"], [])
            self.assertFalse(body["isReminderOn"])
            self.assertFalse(body["isOnlineMeeting"])
            self.assertEqual(body["showAs"], "free")
            probe.date_roundtrip(body, fixture)

    def test_utc_shifted_all_day_is_rejected(self):
        fixture = probe.fixtures(2026)[0]
        body = probe.event_body(fixture, "marker", "transaction")
        body["start"]["dateTime"] = "2026-03-28T23:00:00"
        with self.assertRaisesRegex(probe.ProbeError, "all_day_roundtrip_failed"):
            probe.date_roundtrip(body, fixture)

    def test_account_and_tenant_must_both_match(self):
        self.assertTrue(probe.account_matches({"tid": CONFIG["tenant_id"], "oid": CONFIG["expected_object_id"]}, CONFIG))
        self.assertFalse(probe.account_matches({"tid": CONFIG["client_id"], "oid": CONFIG["expected_object_id"]}, CONFIG))
        self.assertFalse(probe.account_matches({"tid": CONFIG["tenant_id"], "oid": CONFIG["client_id"]}, CONFIG))
        self.assertFalse(probe.account_matches({}, CONFIG))

    def test_personal_authority_and_explicit_account_binding(self):
        config = {**CONFIG, "tenant_id": probe.CONSUMER_TENANT, "mailbox_type": "personal",
                  "expected_object_id": "00000000-0000-0000-0000-000000000000"}
        with patch("msal.PublicClientApplication") as client:
            identity = probe.Identity(config)
        self.assertEqual(client.call_args.kwargs["authority"], "https://login.microsoftonline.com/consumers")
        identity.app.acquire_token_interactive.return_value = {
            "access_token": "SYNTHETIC_TOKEN", "id_token_claims": {
                "tid": probe.CONSUMER_TENANT, "oid": CONFIG["expected_object_id"]}}
        identity.app.get_accounts.return_value = [{"local_account_id": CONFIG["expected_object_id"]}]
        with patch("builtins.input", return_value=""):
            with self.assertRaisesRegex(probe.ProbeError, "account_binding_not_confirmed"):
                identity.connect(binding=True)
        self.assertEqual(config["expected_object_id"], "00000000-0000-0000-0000-000000000000")
        with patch("builtins.input", return_value="BIND"):
            identity.connect(binding=True)
        self.assertEqual(config["expected_object_id"], CONFIG["expected_object_id"])

    def test_bind_command_writes_only_identifier_without_graph_calls(self):
        path = Path(self.temporary.name) / "config.json"
        config = {**CONFIG, "expected_object_id": "00000000-0000-0000-0000-000000000000"}
        path.write_text(json.dumps(config), encoding="utf-8")
        def identity_factory(received):
            def connect(binding=False):
                self.assertTrue(binding)
                received["expected_object_id"] = CONFIG["expected_object_id"]
            return Mock(connect=connect)
        output = io.StringIO()
        with patch("probe.Identity", side_effect=identity_factory), patch("probe.Graph") as graph, patch("sys.stdout", output):
            self.assertEqual(probe.main(["bind", "--config", str(path), "--allow-live"]), 0)
        graph.assert_not_called()
        self.assertEqual(json.loads(path.read_text(encoding="utf-8")), CONFIG)
        self.assertEqual(json.loads(output.getvalue())["graph_calls"], 0)
        self.assertNotIn(CONFIG["expected_object_id"], output.getvalue())
        with self.assertRaisesRegex(probe.ProbeError, "binding_requires_unbound_configuration"):
            probe.load_config(path, binding=True)

    def test_config_requires_account_consent_and_no_placeholders(self):
        path = Path(self.temporary.name) / "config.json"
        for field, value in (("client_id", "00000000-0000-0000-0000-000000000000"),
                             ("consent_confirmed", False), ("dedicated_test_mailbox", False),
                             ("mailbox_type", "unknown"), ("year", "2026")):
            path.write_text(json.dumps({**CONFIG, field: value}), encoding="utf-8")
            with self.assertRaises(probe.ProbeError):
                probe.load_config(path)

    def test_state_outside_git_and_bound_to_account(self):
        with self.assertRaisesRegex(probe.ProbeError, "state_must_be_outside_repository"):
            probe.private_path(probe.ROOT / "probe-state.json")
        with self.assertRaisesRegex(probe.ProbeError, "journal_account_mismatch"):
            probe.Journal(self.state, {**CONFIG, "expected_object_id": CONFIG["client_id"]}, existing=True)
        with self.assertRaisesRegex(probe.ProbeError, "journal_already_exists"):
            probe.Journal(self.state, CONFIG)

    def test_unrecorded_id_cannot_be_modified(self):
        with self.assertRaisesRegex(probe.ProbeError, "unowned_event"):
            self.owner.mutate({"id": "foreign"}, "DELETE")
        self.assertEqual(self.graph.calls, [])

    def test_ownership_and_attendee_guards(self):
        intent = self.owner.create(probe.fixtures(2026)[0])
        event = self.graph.events[intent["id"]]
        pristine = copy.deepcopy(event)
        for mutation in ({"transactionId": "foreign"}, {"singleValueExtendedProperties": []},
                         {"attendees": [{"emailAddress": {"address": "synthetic@example.invalid"}}]}):
            event.clear()
            event.update(copy.deepcopy(pristine))
            event.update(mutation)
            before = len([c for c in self.graph.calls if c[0] in {"DELETE", "PATCH"}])
            with self.assertRaises(probe.ProbeError):
                self.owner.mutate(intent, "DELETE")
            self.assertEqual(before, len([c for c in self.graph.calls if c[0] in {"DELETE", "PATCH"}]))

    def test_ambiguous_post_recovered_by_saved_marker_and_transaction(self):
        original = self.graph.request

        def timeout_after_create(method, *args, **kwargs):
            result = original(method, *args, **kwargs)
            if method == "POST":
                raise probe.ProbeError("graph_transport_failure")
            return result

        self.graph.request = timeout_after_create
        with self.assertRaises(probe.ProbeError):
            self.owner.create(probe.fixtures(2026)[0])
        self.assertIsNone(self.journal.data["intents"][0]["id"])
        self.owner.cleanup()
        self.assertFalse(self.graph.events)
        self.assertTrue(self.journal.data["intents"][0]["deleted"])

    def test_ambiguous_create_with_no_match_stays_unresolved(self):
        self.graph.request = Mock(side_effect=probe.ProbeError("graph_transport_failure"))
        with self.assertRaises(probe.ProbeError):
            self.owner.create(probe.fixtures(2026)[0])
        self.graph.request = Mock(return_value={"value": []})
        with self.assertRaisesRegex(probe.ProbeError, "ambiguous_create_requires_operator_recovery"):
            self.owner.cleanup()
        self.assertFalse(self.journal.data["intents"][0]["deleted"])

    def test_delta_preserves_opaque_links_and_discards_private_rows(self):
        first = probe.GRAPH + "/me/calendarView/delta?startDateTime=synthetic"
        next_link = probe.GRAPH + "/me/calendarView/delta?$skiptoken=a%2B%2F%3D"
        final = probe.GRAPH + "/me/calendarView/delta?$deltatoken=opaque%2B"
        graph = Mock()
        graph.request.side_effect = [
            {"value": [{"id": "foreign", "subject": "PRIVATE"}, {"id": "own", "subject": "old"}], "@odata.nextLink": next_link},
            {"value": [{"id": "own", "@removed": {"reason": "deleted"}}, {"id": "foreign", "@removed": {}}], "@odata.deltaLink": final}]
        cursor, rows, removed, pages = probe.delta_round(graph, first, {"own"}, set())
        self.assertEqual((cursor, rows, removed, pages), (final, {}, {"own"}, 2))
        self.assertEqual(graph.request.call_args_list[1].args, ("GET", next_link))

    def test_delta_rejects_host_escape_cycles_and_incomplete_checkpoints(self):
        url = probe.GRAPH + "/me/calendarView/delta"
        for page in ({"value": [], "@odata.nextLink": "https://example.invalid/steal"},
                     {"value": [], "@odata.nextLink": url}, {"value": []}):
            graph = Mock()
            graph.request.return_value = page
            with self.assertRaises(probe.ProbeError):
                probe.delta_round(graph, url, set(), set())
            self.assertEqual(graph.request.call_count, 1)

    def test_untrusted_graph_url_fails_before_token_acquisition(self):
        identity = Mock()
        graph = probe.Graph(identity)
        for url in ("https://graph.microsoft.com.evil.invalid/v1.0/me/events",
                    "http://graph.microsoft.com/v1.0/me/events", "https://graph.microsoft.com/v1.0/me/events#fragment"):
            with self.assertRaises(probe.ProbeError):
                graph.request("GET", url)
        identity.token.assert_not_called()

    def test_graph_errors_do_not_echo_response_or_redirect(self):
        graph = probe.Graph(Mock(token=Mock(return_value="SYNTHETIC_SECRET")))
        response = Mock(status_code=401, text="PRIVATE_CANARY")
        response.__enter__ = Mock(return_value=response)
        response.__exit__ = Mock(return_value=False)
        graph.session.request = Mock(return_value=response)
        with self.assertRaisesRegex(probe.ProbeError, "^reconnect_required$"):
            graph.request("GET", probe.GRAPH + "/me/calendar")
        self.assertFalse(graph.session.request.call_args.kwargs["allow_redirects"])
        response.status_code = 302
        with self.assertRaisesRegex(probe.ProbeError, "^graph_http_302$"):
            graph.request("GET", probe.GRAPH + "/me/calendar")

    def test_refresh_failure_requires_reconnection_without_leaking_description(self):
        identity = probe.Identity.__new__(probe.Identity)
        identity.account = {"synthetic": True}
        identity.app = Mock()
        identity.app.acquire_token_silent_with_error.return_value = {"error": "invalid_grant", "error_description": "PRIVATE"}
        with self.assertRaisesRegex(probe.ProbeError, "^reconnect_required$"):
            identity.token()

    def test_full_simulated_lifecycle_and_redacted_journal(self):
        evidence = {}
        probe.exercise(self.graph, self.journal, 2026, evidence)
        for name in ("initial_delta", "create_all_day_dst", "recurrence_occurrences", "incremental_create",
                     "update_readback", "incremental_update", "delete_readback", "incremental_delete"):
            self.assertEqual(evidence[name], "passed")
        self.assertEqual(evidence["pagination"], "observed")
        self.assertFalse(self.graph.events)
        serialized = self.state.read_text(encoding="utf-8")
        for forbidden in ("PRIVATE_SYNTHETIC_CANARY", "access_token", "refresh_token", "deltaLink", "NEVER_LOG_THIS"):
            self.assertNotIn(forbidden, serialized)

    def test_missing_delta_change_does_not_pass(self):
        request = self.graph.request

        def omit_updates(method, url, *args, **kwargs):
            response = request(method, url, *args, **kwargs)
            if "/calendarView/delta" in url:
                response["value"] = []
            return response

        self.graph.request = omit_updates
        with patch("probe.time.sleep"), self.assertRaisesRegex(probe.ProbeError, "incremental_create_not_observed"):
            probe.exercise(self.graph, self.journal, 2026, {})
        self.owner.cleanup()
        self.assertFalse(self.graph.events)

    def test_cli_is_offline_by_default_and_rejects_live_example(self):
        for argv in (["plan"], ["run"], ["run", "--allow-live", "--config", str(Path(__file__).with_name("config.example.json"))]):
            output = io.StringIO()
            with patch("probe.Identity") as identity, patch("sys.stdout", output):
                code = probe.main(argv)
            identity.assert_not_called()
            report = json.loads(output.getvalue())
            self.assertFalse(report["calendar_probe_passed"])
            self.assertFalse(report["integration_verified"])
            self.assertEqual(code, 0 if argv[0] == "plan" else 1)


if __name__ == "__main__":
    unittest.main()
