#!/usr/bin/env python3
"""Local HO-004 demonstration; uses private synthetic accounts and preserves existing plans."""
import argparse
from datetime import date, timedelta
import json
import os
from pathlib import Path
import sys
import urllib.error
import urllib.parse
import urllib.request
import uuid

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--accounts', type=Path, required=True)
    parser.add_argument('--api', default='http://localhost:5080')
    parser.add_argument('--new-run', action='store_true', help='Choose a fresh unused window; previous synthetic plans remain')
    args = parser.parse_args()
    parsed = urllib.parse.urlsplit(args.api)
    if parsed.hostname not in {'localhost', '127.0.0.1', '::1'} or parsed.scheme != 'http' or parsed.username or parsed.query or parsed.fragment:
        raise SystemExit('This demonstration only accepts a loopback HTTP Development API.')
    private = args.accounts.resolve()
    if private.is_relative_to(ROOT):
        raise SystemExit('Accounts and demonstration journal must be outside the repository.')
    accounts = json.loads(private.read_text(encoding='utf-8-sig'))
    for role in ('employee', 'manager'):
        if not accounts[role]['email'].endswith('@homeoffice.example'):
            raise SystemExit('Use the documented private synthetic development accounts.')
    journal_path = private.parent / 'ho004-demo.json'
    state = {} if args.new_run or not journal_path.exists() else json.loads(journal_path.read_text())
    tokens = {}

    def save():
        temporary = journal_path.with_suffix('.tmp')
        temporary.write_text(json.dumps(state, indent=2) + '\n', encoding='utf-8')
        os.chmod(temporary, 0o600)
        temporary.replace(journal_path)

    def http(role, path, payload=None, key=None):
        headers = {'Content-Type': 'application/json'}
        if role in tokens:
            headers['Authorization'] = 'Bearer ' + tokens[role]
        if key:
            headers['Idempotency-Key'] = key
        request = urllib.request.Request(args.api.rstrip('/') + path, headers=headers,
                                         data=None if payload is None else json.dumps(payload).encode())
        try:
            with urllib.request.urlopen(request, timeout=20) as response:
                body = response.read()
                return json.loads(body) if body else None
        except urllib.error.HTTPError as error:
            # Do not print bodies, credentials, tokens, comments or unrelated calendar contents.
            raise SystemExit(f'API returned HTTP {error.code}. Journal preserved; consult the local guide.') from None
        except urllib.error.URLError:
            raise SystemExit('Local API is unreachable; journal preserved.') from None

    for role in ('employee', 'manager'):
        tokens[role] = http(role, '/api/v1/auth/token/login', {k: accounts[role][k] for k in ('email', 'password')})['accessToken']
    employee = http('employee', '/api/v1/me')['memberId']
    base = f'/api/v1/planning/{employee}'
    if state and (state.get('employee') != employee or state.get('api') != args.api):
        raise SystemExit('Existing journal belongs to another account/API; explicitly use --new-run.')

    if not state:
        start = date.today() + timedelta(days=30)
        end = start + timedelta(days=330)
        view = http('employee', f'{base}/calendar?from={start}&to={end}')
        busy = {d['localDate'] for d in view['effectiveDays'] if d['origin'] == 'ApprovedRequest'}
        busy.update(p['day']['localDate'] for p in view['pendingDays'])
        choices = [d['localDate'] for d in view['effectiveDays'] if d['localDate'] not in busy and date.fromisoformat(d['localDate']).weekday() < 5]
        if len(choices) < 3:
            raise SystemExit('No unused demonstration window available; no planning changes made.')
        state = {'employee': employee, 'api': args.api, 'dates': choices[:3], 'steps': {}}
        save()

    def calendar():
        return http('employee', f"{base}/calendar?from={state['dates'][0]}&to={state['dates'][-1]}")

    def request(receipt):
        return http('employee', base + '/requests/' + receipt['contextId'])

    def step(name, role, path, make_payload):
        entry = state['steps'].get(name)
        if entry is None:
            entry = {'key': uuid.uuid4().hex, 'payload': make_payload(), 'path': path}
            state['steps'][name] = entry
            save()  # Persist the exact command/key before sending; retries cannot duplicate effects.
        if 'receipt' not in entry:
            entry['receipt'] = http(role, entry['path'], entry['payload'], entry['key'])
            save()
        print(name + ': confirmed (durable receipt)')
        return entry['receipt']

    def version():
        return calendar()['calendarVersion']

    def select(days):
        return [{'dayId': d['id'], 'expectedVersion': d['version']} for d in days]

    draft = step('draft', 'employee', base + '/requests', lambda: {
        'expectedCalendarVersion': version(), 'expectedRequestVersion': None, 'parentRevisionId': None,
        'note': 'HO-004 synthetic demonstration', 'days': [{'localDate': d, 'location': 'RemotePortugal', 'availability': 'Working'} for d in state['dates']]})
    path = base + '/requests/' + draft['contextId']
    step('submit', 'employee', path + '/submit', lambda: {'expectedCalendarVersion': version(), 'expectedRequestVersion': request(draft)['version']})
    step('partial-approval', 'manager', path + '/decide', lambda: {'expectedCalendarVersion': version(), 'expectedRequestVersion': request(draft)['version'],
        'days': select(request(draft)['days'][:2]), 'approve': True, 'reason': 'Synthetic partial decision'})
    step('withdraw-pending-day', 'employee', path + '/withdraw', lambda: {'expectedCalendarVersion': version(), 'expectedRequestVersion': request(draft)['version'], 'days': select(request(draft)['days'][2:])})

    def revision_payload():
        original = calendar()['effectiveDays'][0]
        return {'expectedCalendarVersion': version(), 'expectedRequestVersion': None, 'parentRevisionId': draft['contextId'],
                'note': 'Synthetic explicit revision', 'days': [{'localDate': state['dates'][0], 'location': 'OfficeSwitzerland', 'availability': 'Working',
                    'baseDayId': original['sourceDayId'], 'basePlanVersion': original['version']}]}
    revision = step('revision-draft', 'employee', base + '/requests', revision_payload)
    revision_path = base + '/requests/' + revision['contextId']
    step('revision-submit', 'employee', revision_path + '/submit', lambda: {'expectedCalendarVersion': version(), 'expectedRequestVersion': request(revision)['version']})
    if 'revision-approve' not in state['steps']:
        current = calendar()
        if current['effectiveDays'][0]['location'] != 'RemotePortugal':
            raise SystemExit('The previous approval was not preserved; stop and inspect the test journal.')
        print('Pending revision: original RemotePortugal approval remains effective.')
    step('revision-approve', 'manager', revision_path + '/decide', lambda: {'expectedCalendarVersion': version(), 'expectedRequestVersion': request(revision)['version'],
        'days': select(request(revision)['days']), 'approve': True, 'reason': 'Synthetic revision decision'})
    view = calendar()
    print('Calendar for this demonstration only:')
    for day in view['effectiveDays']:
        if day['localDate'] in state['dates']:
            print(json.dumps({k: day[k] for k in ('localDate', 'location', 'availability', 'origin')}))
    print('Credentials stayed private. No notification delivery or external integration performed.')
    print('Repeat this command to reuse receipts, or add --new-run for fresh unused dates.')


if __name__ == '__main__':
    main()
