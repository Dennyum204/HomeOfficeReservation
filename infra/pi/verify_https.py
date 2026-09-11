#!/usr/bin/env python3
"""Private origin verification; no Cloudflare connection or public DNS lookup/mutation.

Tests use a network-namespace client in place of cloudflared, not live Cloudflare evidence.
Caller must back up the trial first. Existing configuration files/keys are never edited.
"""
import argparse
import http.client
from http.cookies import SimpleCookie
import json
import os
from pathlib import Path
import socket
import ssl
import subprocess
import time
import traceback

from prepare_https import HOST, CONNECTOR_IMAGE, prepare_https


class OriginConnection(http.client.HTTPSConnection):
    def connect(self):
        sock = socket.create_connection(('10.78.18.2', 443), self.timeout)
        self.sock = self._context.wrap_socket(sock, server_hostname=HOST)


def client_tests(folder, trusted):
    private = folder / 'private'
    context = ssl.create_default_context(cafile=str(private / 'https/origin.pem'))
    cookies = {}

    def request(path, body=None, expected=200, csrf=False, bearer=None, ip='192.0.2.10', xff='203.0.113.9'):
        headers = {'Content-Type': 'application/json', 'CF-Connecting-IP': ip,
                   'X-Forwarded-For': xff, 'X-Forwarded-Proto': 'http',
                   'Forwarded': 'for=203.0.113.9;proto=http;host=attacker.invalid',
                   'Origin': 'https://' + HOST}
        if csrf:
            headers['X-CSRF-TOKEN'] = request('/api/v1/auth/csrf')['requestToken']
        if bearer:
            headers['Authorization'] = 'Bearer ' + bearer
        elif cookies:
            headers['Cookie'] = '; '.join(k + '=' + v for k, v in cookies.items())
        connection = OriginConnection(HOST, context=context, timeout=20)
        connection.request('GET' if body is None else 'POST', path,
                           None if body is None else json.dumps(body), headers)
        response = connection.getresponse()
        data = response.read()
        if response.status != expected:
            raise RuntimeError(f'Origin check {path}: HTTP {response.status}, expected {expected}; payload withheld')
        for name, value in response.getheaders():
            if name.lower() == 'set-cookie':
                parsed = SimpleCookie(value)
                for key, morsel in parsed.items():
                    if key.startswith('HomeOffice.'):
                        assert morsel['secure'] and morsel['httponly']
                        assert morsel['samesite'].lower() in ('lax', 'strict')
                        cookies[key] = morsel.value
        connection.close()
        return json.loads(data) if data and 'json' in response.getheader('Content-Type', '') else data

    if not trusted:
        request('/api/v1/me', expected=403)
        return {'untrusted_origin_peer': '403 despite forged forwarding headers'}
    assert b'<div id="root">' in request('/')
    request('/api/v1/me', expected=401)
    for path in ['/health/live', '/health/ready', '/openapi/v1.json', '/metrics']:
        request(path, expected=404)
    request('/api/v1/auth/register', {}, expected=404)
    credentials = json.loads((private / 'CREDENCIAIS.json').read_text(encoding='utf-8'))
    request('/api/v1/auth/web/login', credentials['owner'], expected=400)
    request('/api/v1/auth/web/login', credentials['owner'], csrf=True, expected=204)
    profile = request('/api/v1/me')
    assert profile['isAccountAdministrator'] and profile['isEmployee']
    request('/api/v1/auth/logout', {}, expected=400)
    request('/api/v1/auth/logout', {}, csrf=True, expected=204)
    request('/api/v1/me', expected=401)
    tokens = request('/api/v1/auth/token/login', credentials['manager'])
    assert request('/api/v1/me', bearer=tokens['accessToken'])['isManager']
    refreshed = request('/api/v1/auth/token/refresh', {'refreshToken': tokens['refreshToken']})
    assert request('/api/v1/me', bearer=refreshed['accessToken'])['isManager']
    # Existing API rate limiter uses RemoteIpAddress. Spoofed XFF must not change its key.
    for n in range(30):
        request('/api/v1/auth/csrf', ip='192.0.2.20', xff='203.0.113.' + str(n + 1))
    request('/api/v1/auth/csrf', ip='192.0.2.20', xff='198.51.100.1', expected=429)
    request('/api/v1/auth/csrf', ip='192.0.2.21')
    return {'origin_tls': 'verified private CA and SNI', 'cookie_secure_httponly_samesite': True,
            'web_login_csrf_logout': True, 'android_bearer_login_refresh': True,
            'anonymous_member_read': '401', 'public_registration': 'not mapped',
            'private_endpoints': '404', 'forwarding_spoof_rate_limit': 'passed',
            'cloudflare_live': False, 'android_device': False}


def verify(folder):
    folder = Path(folder).resolve()
    target = folder / 'private/https'
    if not target.exists():
        prepare_https(folder)
    # No reused diagnostic files/containers, no token ever required by this validation.
    receipt = target / 'verification.json'
    if receipt.exists():
        raise RuntimeError('Validation receipt exists; inspect it before repeating.')
    project = 'homeoffice-pi-trial'
    base = ['docker', 'compose', '-p', project, '-f', str(folder / 'compose.yaml')]
    overlay = base + ['-f', str(target / 'compose.json')]

    def command(args):
        result = subprocess.run(args, cwd=folder, capture_output=True, timeout=180)
        if result.returncode:
            if args[0] == 'nsenter':
                # Child emits only allowlisted, sanitised failure metadata, never payloads/tokens.
                try:
                    detail = json.loads(result.stdout)
                except (ValueError, UnicodeError):
                    detail = {'error': 'client_process_failed_before_sanitized_receipt'}
                raise RuntimeError('Origin client failed: ' + json.dumps(detail))
            raise RuntimeError('HTTPS validation command failed (' + args[0] + '); no secret output printed')
        return result.stdout

    meta = json.loads(command(['docker', 'image', 'inspect', CONNECTOR_IMAGE]))[0]
    assert meta['Architecture'] == 'arm64' and meta['Os'] == 'linux'
    command(['docker', 'run', '--rm', '--network', 'none', CONNECTOR_IMAGE, '--version'])
    command(['docker', 'run', '--rm', '--network', 'none', '--user', '0:0',
             '-v', str(target) + ':/check:ro', CONNECTOR_IMAGE,
             'tunnel', '--config', '/check/ingress.json', 'ingress', 'validate'])
    effective = json.loads(command(overlay + ['--profile', 'publish', 'config', '--format', 'json']))
    assert set(effective['services']) == {'app', 'database', 'edge', 'mailpit', 'cloudflared'}
    for service in effective['services'].values():
        assert not service.get('ports') and service['restart'] == 'unless-stopped'
    assert set(effective['services']['cloudflared']['networks']) == {'tunnel_origin', 'tunnel_egress'}
    assert effective['networks']['tunnel_origin']['internal']
    # Ensure the app config preserves its data/identity/SMTP and trust boundary.
    original = json.loads((folder / 'private/application.json').read_text(encoding='utf-8'))
    staged = json.loads((target / 'application.json').read_text(encoding='utf-8'))
    for key in original.keys() - {'AllowedHosts', 'Hosting'}:
        assert original[key] == staged[key]
    assert staged['Hosting']['KnownProxies'] == original['Hosting']['KnownProxies'] == '10.78.17.2'
    os.chown(target / 'application.json', 1654, 1654)
    # Reserve the future connector address with an offline client, no egress or token.
    name = 'homeoffice-https-origin-validation'
    if subprocess.run(['docker', 'inspect', name], capture_output=True).returncode == 0:
        raise RuntimeError('Validation container name collision; preserving existing container.')
    started = False
    try:
        command(overlay + ['up', '-d', '--no-deps', '--pull', 'never', 'app', 'edge'])
        edge_image = effective['services']['edge']['image']
        command(['docker', 'run', '-d', '--name', name, '--network', project + '_tunnel_origin',
                 '--ip', '10.78.18.3', '--memory', '64m', '--memory-swap', '64m', '--cpus', '0.25',
                 '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges:true',
                 '--entrypoint', 'sleep', edge_image, '300'])
        started = True
        time.sleep(8)
        client_tests(folder, trusted=False)
        pid = json.loads(command(['docker', 'inspect', name]))[0]['State']['Pid']
        result = command(['nsenter', '-t', str(pid), '-n', 'python3', str(Path(__file__).resolve()),
                          '--client', str(folder)])
        evidence = json.loads(result)
        evidence['connector_image_id'] = meta['Id']
        evidence['connector_digests'] = meta.get('RepoDigests', [])
        evidence['connector_arm64_cli_ingress_validation'] = True
        evidence['untrusted_origin_peer'] = '403'
        evidence['no_dns_or_tunnel_connection'] = True
        receipt.write_text(json.dumps(evidence, indent=2) + '\n', encoding='utf-8', newline='\n')
        receipt.chmod(0o600)
    finally:
        if started:
            command(['docker', 'rm', '-f', name])
        # Original mounts/config/ports/restart policy, no database/volume deletion or migrations.
        command(base + ['up', '-d', '--no-deps', '--pull', 'never', 'app', 'edge'])
    return evidence


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--client', type=Path)
    args = parser.parse_args()
    if not args.client:
        parser.error('Use the guarded CI/Pi wrapper; direct apply is not exposed.')
    try:
        print(json.dumps(client_tests(args.client, trusted=True)))
    except Exception as error:
        detail = {'error': type(error).__name__,
                  'lines': [frame.lineno for frame in traceback.extract_tb(error.__traceback__)]}
        if isinstance(error, RuntimeError):
            detail['check'] = str(error)  # All RuntimeErrors above exclude bodies/credentials.
        print(json.dumps(detail))
        raise SystemExit(1) from None
