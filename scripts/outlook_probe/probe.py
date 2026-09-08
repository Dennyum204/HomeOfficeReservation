"""HO-001 local Graph probe. No application scaffold; no persistent token cache."""
from __future__ import annotations

import argparse
import calendar
import hashlib
import json
import logging
import os
from pathlib import Path
import time
from datetime import date, datetime, timedelta, timezone
from urllib.parse import quote, urlencode, urlsplit
from uuid import UUID, uuid4
from zoneinfo import ZoneInfo

ROOT = Path(__file__).resolve().parents[2]
GRAPH = "https://graph.microsoft.com/v1.0"
SCOPES = ["https://graph.microsoft.com/Calendars.ReadWrite"]
PROPERTY = "String {10b7338a-820c-4518-a32e-146dd4a21bc7} Name HO001ProbeRun"
ZONES = {"Europe/Lisbon": "GMT Standard Time", "Europe/Zurich": "W. Europe Standard Time"}
CONSUMER_TENANT = "9188040d-6c67-4c5b-b112-36a304b66dad"


class ProbeError(Exception):
    """Only fixed, non-sensitive error codes may cross the CLI boundary."""


def require(condition, code):
    if not condition:
        raise ProbeError(code)


def guid(value):
    try:
        parsed = UUID(value)
        require(parsed.int != 0, "configuration_placeholder")
        return str(parsed)
    except (ValueError, TypeError, AttributeError):
        raise ProbeError("configuration_uuid") from None


def load_config(path, binding=False):
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    for key in ("tenant_id", "client_id"):
        data[key] = guid(data.get(key))
    if binding:
        require(data.get("expected_object_id") == "00000000-0000-0000-0000-000000000000",
                "binding_requires_unbound_configuration")
    else:
        data["expected_object_id"] = guid(data.get("expected_object_id"))
    require(data.get("mailbox_type") in {"organizational", "personal"}, "mailbox_type_required")
    require((data["tenant_id"] == CONSUMER_TENANT) == (data["mailbox_type"] == "personal"),
            "mailbox_tenant_mismatch")
    require(data.get("dedicated_test_mailbox") is True, "dedicated_test_mailbox_required")
    require(data.get("consent_confirmed") is True, "consent_confirmation_required")
    require(type(data.get("year")) is int and 2000 <= data["year"] <= 2100, "configuration_year")
    return data


def account_matches(claims, config):
    # Claims come from MSAL's OIDC result, never a caller-supplied JWT.
    return (claims.get("tid", "").lower() == config["tenant_id"]
            and claims.get("oid", "").lower() == config["expected_object_id"])


class Identity:
    def __init__(self, config):
        import msal
        self.config = config
        authority = "consumers" if config["mailbox_type"] == "personal" else config["tenant_id"]
        self.app = msal.PublicClientApplication(
            config["client_id"], authority="https://login.microsoftonline.com/" + authority,
            enable_pii_log=False)
        self.account = None

    def connect(self, binding=False):
        result = self.app.acquire_token_interactive(SCOPES, prompt="select_account", port=8400)
        require("access_token" in result, "interactive_authentication_failed")
        if binding:
            claims = result.get("id_token_claims", {})
            require(claims.get("tid", "").lower() == self.config["tenant_id"], "wrong_test_tenant")
            identifier = guid(claims.get("oid"))
            require(input("Bind the dedicated test account you explicitly selected in the browser? Type BIND: ")
                    == "BIND", "account_binding_not_confirmed")
            self.config["expected_object_id"] = identifier
        require(account_matches(result.get("id_token_claims", {}), self.config), "wrong_test_account")
        accounts = [a for a in self.app.get_accounts()
                    if a.get("local_account_id", "").lower() == self.config["expected_object_id"]]
        require(len(accounts) == 1, "account_cache_binding_failed")
        self.account = accounts[0]

    def token(self):
        require(self.account is not None, "account_not_connected")
        result = self.app.acquire_token_silent_with_error(SCOPES, account=self.account)
        require(result and "access_token" in result, "reconnect_required")
        return result["access_token"]

    def revocation_check(self):
        # Operator revokes only this probe's grant. No account-wide revoke API.
        input("After cleanup, revoke ONLY this probe app's consent in the account portal; press Enter. ")
        result = self.app.acquire_token_silent_with_error(SCOPES, account=self.account, force_refresh=True)
        observed = bool(result and result.get("error") in {"invalid_grant", "interaction_required"})
        self.app.remove_account(self.account)  # Local cache removal is NOT proof of revocation.
        self.account = None
        self.connect()
        return "refresh_denied_then_reconnected" if observed else "revocation_not_observed_reconnected"


def checked_url(url, expected_path):
    p = urlsplit(url)
    require(p.scheme == "https" and p.netloc == "graph.microsoft.com" and not p.fragment
            and p.path == expected_path, "untrusted_graph_link")
    return url


class Graph:
    def __init__(self, identity):
        import requests
        self.identity = identity
        self.session = requests.Session()
        self.session.trust_env = False  # No .netrc credentials or implicit proxy overrides.

    def request(self, method, url, payload=None, zone=None, etag=None, missing_ok=False):
        p = urlsplit(url)
        checked_url(url, p.path)
        require(p.path.startswith("/v1.0/me/"), "unexpected_graph_resource")
        headers = {"Authorization": "Bearer " + self.identity.token(),
                   "Prefer": 'IdType="ImmutableId", odata.maxpagesize=2',
                   "Accept": "application/json"}
        if zone:
            require(zone in ZONES.values(), "unsupported_probe_zone")
            headers["Prefer"] += ', outlook.timezone="' + zone + '"'
        if etag:
            headers["If-Match"] = etag
        # No automatic POST retry after ambiguous transport failure.
        try:
            response = self.session.request(method, url, json=payload, headers=headers,
                                            timeout=(10, 30), allow_redirects=False)
        except Exception:
            raise ProbeError("graph_transport_failure") from None
        with response:
            if missing_ok and response.status_code == 404:
                return None
            if response.status_code == 401:
                raise ProbeError("reconnect_required")
            require(response.status_code in {200, 201, 204}, "graph_http_" + str(response.status_code))
            return response.json() if response.status_code != 204 else None


def last_sunday(year, month):
    d = date(year, month, calendar.monthrange(year, month)[1])
    return d - timedelta(days=(d.weekday() + 1) % 7)


def fixtures(year):
    result = []
    for iana, windows in ZONES.items():
        for month in (3, 10):
            result.append({"day": last_sunday(year, month).isoformat(), "zone": windows,
                           "iana": iana, "recurring": False})
        result.append({"day": (last_sunday(year, 3) - timedelta(days=1)).isoformat(),
                       "zone": windows, "iana": iana, "recurring": True})
    return result


def event_body(fixture, marker, transaction):
    day = date.fromisoformat(fixture["day"])
    zone = fixture["zone"]
    body = {"subject": "HO001 synthetic probe", "isAllDay": True,
            "start": {"dateTime": day.isoformat() + "T00:00:00", "timeZone": zone},
            "end": {"dateTime": (day + timedelta(days=1)).isoformat() + "T00:00:00", "timeZone": zone},
            "attendees": [], "isReminderOn": False, "showAs": "free", "sensitivity": "private",
            "isOnlineMeeting": False, "transactionId": transaction,
            "singleValueExtendedProperties": [{"id": PROPERTY, "value": marker}]}
    if fixture["recurring"]:
        body["recurrence"] = {"pattern": {"type": "daily", "interval": 1},
                              "range": {"type": "numbered", "startDate": day.isoformat(),
                                        "numberOfOccurrences": 3, "recurrenceTimeZone": zone}}
    return body


def date_roundtrip(event, fixture):
    expected = date.fromisoformat(fixture["day"])
    require(event.get("isAllDay") is True, "all_day_flag_failed")
    for key, day in (("start", expected), ("end", expected + timedelta(days=1))):
        value = event.get(key, {})
        parsed = datetime.fromisoformat(value.get("dateTime", ""))
        require(parsed.replace(tzinfo=None) == datetime.combine(day, datetime.min.time())
                and value.get("timeZone") == fixture["zone"], "all_day_roundtrip_failed")


def utc_duration(fixture):
    d = date.fromisoformat(fixture["day"])
    zone = ZoneInfo(fixture["iana"])
    start = datetime.combine(d, datetime.min.time(), zone).astimezone(timezone.utc)
    end = datetime.combine(d + timedelta(days=1), datetime.min.time(), zone).astimezone(timezone.utc)
    return (end - start).total_seconds() / 3600


def fingerprint(config):
    return hashlib.sha256("|".join(config[k] for k in ("tenant_id", "client_id", "expected_object_id"))
                          .encode()).hexdigest()


def private_path(path):
    resolved = Path(path).expanduser().resolve()
    require(resolved != ROOT and ROOT not in resolved.parents, "state_must_be_outside_repository")
    return resolved


class Journal:
    def __init__(self, path, config, existing=False):
        self.path = private_path(path)
        if existing:
            self.data = json.loads(self.path.read_text(encoding="utf-8"))
            require(self.data.get("account") == fingerprint(config), "journal_account_mismatch")
            guid(self.data.get("marker"))
        else:
            require(not self.path.exists(), "journal_already_exists_use_cleanup")
            self.data = {"account": fingerprint(config), "marker": str(uuid4()), "intents": []}
            self.save()

    def save(self):
        self.path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        temporary = self.path.with_suffix(".tmp")
        fd = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            json.dump(self.data, stream)
        os.replace(temporary, self.path)


def collection(graph, url, zone=None):
    expected = urlsplit(url).path
    seen = set()
    for _ in range(100):
        checked_url(url, expected)
        require(url not in seen, "pagination_cycle")
        seen.add(url)
        page = graph.request("GET", url, zone=zone)
        require(isinstance(page.get("value"), list), "invalid_collection")
        yield from page["value"]
        url = page.get("@odata.nextLink")
        if not url:
            return
    raise ProbeError("pagination_limit")


class OwnedEvents:
    def __init__(self, graph, journal):
        self.graph, self.journal = graph, journal

    def create(self, fixture):
        intent = {"fixture": fixture, "transaction": str(uuid4()), "id": None, "deleted": False}
        self.journal.data["intents"].append(intent)
        self.journal.save()  # Persist intent before an ambiguous POST can occur.
        response = self.graph.request("POST", GRAPH + "/me/events",
                                      event_body(fixture, self.journal.data["marker"], intent["transaction"]),
                                      zone=fixture["zone"])
        require(isinstance(response.get("id"), str) and bool(response["id"]), "create_missing_id")
        intent["id"] = response["id"]
        self.journal.save()
        return intent

    def read(self, intent):
        require(intent in self.journal.data["intents"] and bool(intent.get("id")), "unowned_event")
        url = GRAPH + "/me/events/" + quote(intent["id"], safe="") + "?" + urlencode({
            "$select": "id,transactionId,attendees,subject,isAllDay,start,end,type",
            "$expand": "singleValueExtendedProperties($filter=id eq '" + PROPERTY + "')"})
        event = self.graph.request("GET", url, zone=intent["fixture"]["zone"], missing_ok=True)
        if event is None:
            return None
        require(event.get("id") == intent["id"] and event.get("transactionId") == intent["transaction"],
                "event_identity_mismatch")
        require(any(p.get("id") == PROPERTY and p.get("value") == self.journal.data["marker"]
                    for p in event.get("singleValueExtendedProperties", [])), "ownership_marker_mismatch")
        require(event.get("attendees") == [], "attendees_added_refuse_mutation")
        return event

    def mutate(self, intent, method):
        require(method in {"PATCH", "DELETE"}, "invalid_mutation")
        event = self.read(intent)
        if event is None and method == "DELETE":
            intent["deleted"] = True
            self.journal.save()
            return
        require(event is not None, "owned_event_missing")
        require(bool(event.get("@odata.etag")), "event_etag_missing")
        self.graph.request(method, GRAPH + "/me/events/" + quote(intent["id"], safe=""),
                           {"subject": "HO001 synthetic probe updated"} if method == "PATCH" else None,
                           etag=event["@odata.etag"], missing_ok=method == "DELETE")
        if method == "DELETE":
            intent["deleted"] = True
            self.journal.save()

    def cleanup(self):
        # Recover only ambiguous creations matching BOTH a saved random marker and transaction ID.
        unresolved = [i for i in self.journal.data["intents"] if not i["id"]]
        if unresolved:
            url = GRAPH + "/me/events?" + urlencode({"$filter":
                "singleValueExtendedProperties/Any(ep: ep/id eq '" + PROPERTY + "' and ep/value eq '"
                + self.journal.data["marker"] + "')", "$select": "id,transactionId"})
            recovered = list(collection(self.graph, url))
            for intent in unresolved:
                matches = [e for e in recovered if e.get("transactionId") == intent["transaction"]]
                require(len(matches) == 1, "ambiguous_create_requires_operator_recovery")
                intent["id"] = matches[0]["id"]
                self.journal.save()
        for intent in self.journal.data["intents"]:
            if not intent["deleted"]:
                self.mutate(intent, "DELETE")


def delta_round(graph, url, owned_ids, master_ids):
    expected = "/v1.0/me/calendarView/delta"
    observed, removed, seen = {}, set(), set()
    for page_number in range(1, 101):
        checked_url(url, expected)  # Validate before obtaining or transmitting a bearer token.
        require(url not in seen, "pagination_cycle")
        seen.add(url)
        page = graph.request("GET", url)
        require(isinstance(page.get("value"), list), "invalid_delta")
        for row in page["value"]:
            identifier = row.get("id")
            # Discard ALL unrelated calendar contents, even though Graph cannot $select delta.
            if identifier not in owned_ids and row.get("seriesMasterId") not in master_ids:
                continue
            if "@removed" in row:
                removed.add(identifier)
                observed.pop(identifier, None)
            else:
                removed.discard(identifier)
                observed[identifier] = {"subject": row.get("subject"), "type": row.get("type")}
        following, cursor = page.get("@odata.nextLink"), page.get("@odata.deltaLink")
        require(bool(following) != bool(cursor), "invalid_delta_checkpoint")
        if cursor:
            checked_url(cursor, expected)
            return cursor, observed, removed, page_number
        url = following
    raise ProbeError("pagination_limit")


def window(year, month):
    boundary = last_sunday(year, month)
    return {"startDateTime": (boundary - timedelta(days=2)).isoformat() + "T00:00:00Z",
            "endDateTime": (boundary + timedelta(days=3)).isoformat() + "T00:00:00Z"}


def exercise(graph, journal, year, evidence):
    owner = OwnedEvents(graph, journal)
    cursors, ids, masters = {}, set(), set()
    evidence["pagination"] = "not_observed"
    for month in (3, 10):
        cursors[month], _, _, pages = delta_round(
            graph, GRAPH + "/me/calendarView/delta?" + urlencode(window(year, month)), ids, masters)
        if pages > 1:
            evidence["pagination"] = "observed"
    evidence["initial_delta"] = "passed"
    for fixture in fixtures(year):
        intent = owner.create(fixture)
        ids.add(intent["id"])
        date_roundtrip(owner.read(intent), fixture)
        if fixture["recurring"]:
            masters.add(intent["id"])
            url = GRAPH + "/me/events/" + quote(intent["id"], safe="") + "/instances?" + urlencode({
                **window(year, 3), "$select": "id,seriesMasterId,type,isAllDay,start,end"})
            instances = list(collection(graph, url, zone=fixture["zone"]))
            require(len(instances) == 3, "recurrence_count_failed")
            expected_days = {date.fromisoformat(fixture["day"]) + timedelta(days=i) for i in range(3)}
            actual_days = set()
            for row in instances:
                require(row.get("seriesMasterId") == intent["id"] and row.get("type") == "occurrence",
                        "recurrence_ownership_failed")
                day = date.fromisoformat(row["start"]["dateTime"][:10])
                date_roundtrip(row, {**fixture, "day": day.isoformat()})
                actual_days.add(day)
                ids.add(row["id"])
            require(actual_days == expected_days, "recurrence_dates_failed")
    evidence["create_all_day_dst"] = "passed"
    evidence["recurrence_occurrences"] = "passed"

    def observe(stage, expected_ids, predicate):
        matched = set()
        for attempt in range(10):
            for month in (3, 10):
                cursors[month], rows, removed, pages = delta_round(graph, cursors[month], ids, masters)
                if pages > 1:
                    evidence["pagination"] = "observed"
                matched.update(predicate(rows, removed))
            if matched >= expected_ids:
                evidence[stage] = "passed"
                return
            if attempt < 9:
                time.sleep(2)
        raise ProbeError(stage + "_not_observed")

    # calendarView expands series: it returns occurrences, not necessarily the master.
    observe("incremental_create", ids - masters, lambda rows, removed: set(rows))
    first = journal.data["intents"][0]
    owner.mutate(first, "PATCH")
    require(owner.read(first)["subject"] == "HO001 synthetic probe updated", "update_readback_failed")
    evidence["update_readback"] = "passed"
    observe("incremental_update", {first["id"]}, lambda rows, removed: {
        key for key, row in rows.items() if row["subject"] == "HO001 synthetic probe updated"})
    owner.cleanup()
    require(all(owner.read(i) is None for i in journal.data["intents"]), "deletion_readback_failed")
    evidence["delete_readback"] = "passed"
    observe("incremental_delete", ids - masters, lambda rows, removed: removed)


def main(argv=None):
    logging.disable(logging.CRITICAL)  # Never emit MSAL/HTTP URLs or payloads.
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("plan", "bind", "run", "cleanup"))
    parser.add_argument("--config")
    parser.add_argument("--state", default=str(Path.home() / ".ho001-probe" / "state.json"))
    parser.add_argument("--allow-live", action="store_true")
    parser.add_argument("--revocation-check", action="store_true")
    args = parser.parse_args(argv)
    evidence = {"mode": "offline" if args.command == "plan" else "live",
                "started_at": datetime.now(timezone.utc).isoformat(), "calendar_probe_passed": False,
                "integration_verified": False,
                "revocation": "not_run", "production_web_mobile_login": "not_run"}
    journal = owner = identity = None
    exit_code = 0
    try:
        if args.command == "plan":
            cases = fixtures(2026)
            evidence.update({"fixtures": len(cases), "single_day_utc_hours": [
                utc_duration(f) for f in cases if not f["recurring"]], "network_calls": 0})
        else:
            require(args.allow_live and args.config, "explicit_live_configuration_required")
            config = load_config(args.config, binding=args.command == "bind")
            if args.command == "bind":
                # Initial account binding is interactive, performs NO Graph calls, and
                # writes only the selected OIDC identifier into private configuration.
                config_path = private_path(args.config)
                identity = Identity(config)
                identity.connect(binding=True)
                config_path.write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")
                evidence.update({"account_binding": "passed", "graph_calls": 0})
                return 0
            # Validate private state/account binding before opening a browser.
            journal = Journal(args.state, config, existing=args.command == "cleanup")
            identity = Identity(config)
            identity.connect()
            graph = Graph(identity)
            owner = OwnedEvents(graph, journal)
            evidence["account_binding"] = "passed"
            if args.command == "run":
                exercise(graph, journal, config["year"], evidence)
                evidence["calendar_probe_passed"] = True
            else:
                owner.cleanup()
            evidence["cleanup"] = "passed"
            if args.revocation_check:
                evidence["revocation"] = identity.revocation_check()
                graph.request("GET", GRAPH + "/me/calendar?$select=id")
                evidence["reconnection_calendar_read"] = "passed"
    except (Exception, KeyboardInterrupt) as error:
        # Never stringify arbitrary exceptions (they can contain URLs, payloads or tokens).
        evidence["error"] = str(error) if isinstance(error, ProbeError) else "probe_failed_redacted"
        exit_code = 1
    finally:
        if owner and journal and any(not i["deleted"] for i in journal.data["intents"]):
            try:
                owner.cleanup()
                evidence["cleanup"] = "passed"
            except (Exception, KeyboardInterrupt):
                evidence["cleanup"] = "pending_use_same_journal"
                exit_code = 1
        if journal:
            # Receipt contains only fixed outcomes and counts; tokens/cursors never persist.
            report = journal.path.with_name("evidence.json")
            report.write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(evidence, sort_keys=True))
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
