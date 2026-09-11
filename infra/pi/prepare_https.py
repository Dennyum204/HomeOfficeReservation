#!/usr/bin/env python3
"""Stage a private HTTPS overlay; no network calls, token, DNS or running-stack changes."""
import argparse
import copy
import json
import os
from pathlib import Path
import subprocess

HOST = 'homeoffice.ferbatech.com'
CONNECTOR_IMAGE = 'cloudflare/cloudflared:2026.9.1'


def prepare_https(trial):
    trial = Path(trial).resolve()
    if (trial / '.ho012-pi-trial').read_bytes() != b'homeoffice-pi-trial\n':
        raise ValueError('Not a prepared Pi trial.')
    config = json.loads((trial / 'private/application.json').read_text(encoding='utf-8'))
    if config['Hosting']['PublicOrigin'] != 'https://localhost:18443':
        raise ValueError('Expected the original local trial origin; inspect before preparing again.')
    target = trial / 'private/https'
    target.mkdir(mode=0o700, exist_ok=False)

    def write(name, value):
        path = target / name
        path.write_text(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n',
                        encoding='utf-8', newline='\n')
        path.chmod(0o600)

    # Separate origin TLS: never renew/replace the SMTP certificate, DP PFX or key ring.
    subprocess.run(['openssl', 'req', '-x509', '-newkey', 'rsa:3072', '-nodes', '-days', '30',
        '-subj', '/CN=' + HOST, '-addext', 'subjectAltName=DNS:' + HOST + ',IP:10.78.18.2',
        '-addext', 'basicConstraints=critical,CA:TRUE', '-addext', 'keyUsage=digitalSignature,keyEncipherment,keyCertSign',
        '-addext', 'extendedKeyUsage=serverAuth', '-keyout', str(target / 'origin.key'),
        '-out', str(target / 'origin.pem')], check=True, capture_output=True)
    (target / 'origin.key').chmod(0o600)
    # Certificate is public material; containing folder remains restricted.
    (target / 'origin.pem').chmod(0o644)
    public_config = copy.deepcopy(config)
    public_config['AllowedHosts'] = HOST
    public_config['Hosting']['PublicOrigin'] = 'https://' + HOST
    # API still trusts Caddy's existing app-facing IP, not all Cloudflare ranges.
    assert public_config['Hosting']['KnownProxies'] == '10.78.17.2'
    write('application.json', public_config)
    write('Caddyfile', '''{
    auto_https off
    admin off
    servers {
        trusted_proxies static 10.78.18.3/32
        trusted_proxies_strict
        client_ip_headers CF-Connecting-IP
        strict_sni_host on
    }
}
https://homeoffice.ferbatech.com {
    tls /run/origin/origin.pem /run/origin/origin.key
    @untrusted not remote_ip 10.78.18.3
    respond @untrusted 403
    @private path /health /health/* /openapi /openapi/* /metrics /metrics/*
    respond @private 404
    header {
        -Server
        Cache-Control "no-store"
        X-Content-Type-Options nosniff
        Referrer-Policy same-origin
        X-Frame-Options DENY
    }
    reverse_proxy app:8080 {
        header_up Host homeoffice.ferbatech.com
        header_up X-Forwarded-Host homeoffice.ferbatech.com
        header_up X-Forwarded-Proto https
        header_up X-Forwarded-For {client_ip}
        header_up -Forwarded
        header_up -CF-Connecting-IP
    }
}
''')
    ingress = [
        {'hostname': HOST, 'path': '^/(health|openapi|metrics)(/|$)', 'service': 'http_status:404'},
        {'hostname': HOST, 'service': 'https://10.78.18.2:443', 'originRequest': {
            'originServerName': HOST, 'httpHostHeader': HOST,
            'caPool': '/etc/cloudflared/origin.pem', 'noTLSVerify': False}},
        {'service': 'http_status:404'}]
    write('route.json', {'config': {'ingress': ingress, 'warp-routing': {'enabled': False}}})
    write('blocked-route.json', {'config': {'ingress': [{'service': 'http_status:404'}], 'warp-routing': {'enabled': False}}})
    write('ingress.json', {'ingress': ingress})
    overlay = {'services': {
        name: {'restart': 'unless-stopped'} for name in ['app', 'database', 'edge', 'mailpit']},
        'networks': {
            'tunnel_origin': {'internal': True, 'labels': {'org.homeoffice.trial': '${HO_TRIAL_ID}'},
                'ipam': {'config': [{'subnet': '10.78.18.0/29'}]}},
            'tunnel_egress': {'labels': {'org.homeoffice.trial': '${HO_TRIAL_ID}'}}}}
    overlay['services']['app'].update({'environment': {'HO_PUBLIC_HOST': HOST},
        'volumes': ['./private/https/application.json:/run/config/application.json:ro']})
    overlay['services']['edge'].update({'networks': {'trial': {'ipv4_address': '10.78.17.2'},
        'tunnel_origin': {'ipv4_address': '10.78.18.2'}}, 'volumes': [
            './private/https/Caddyfile:/etc/caddy/Caddyfile:ro',
            './private/https/origin.pem:/run/origin/origin.pem:ro',
            './private/https/origin.key:/run/origin/origin.key:ro']})
    overlay['services']['cloudflared'] = {
        'image': CONNECTOR_IMAGE, 'platform': 'linux/arm64', 'pull_policy': 'never',
        'profiles': ['publish'], 'restart': 'unless-stopped', 'user': '65532:65532',
        'read_only': True, 'cap_drop': ['ALL'], 'security_opt': ['no-new-privileges:true'],
        'mem_limit': '128m', 'memswap_limit': '128m', 'cpus': 0.25, 'pids_limit': 64,
        'command': ['tunnel', '--no-autoupdate', '--loglevel', 'warn', '--metrics', '127.0.0.1:2000',
                    'run', '--token-file', '/run/secrets/tunnel-token'],
        'volumes': [
            {'type': 'bind', 'source': './private/https/tunnel-token', 'target': '/run/secrets/tunnel-token',
             'read_only': True, 'bind': {'create_host_path': False}},
            './private/https/origin.pem:/etc/cloudflared/origin.pem:ro'],
        'networks': {'tunnel_origin': {'ipv4_address': '10.78.18.3'}, 'tunnel_egress': {}},
        'logging': {'driver': 'json-file', 'options': {'max-size': '5m', 'max-file': '2'}}}
    write('compose.json', overlay)
    return target


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--trial', required=True)
    args = parser.parse_args()
    prepare_https(args.trial)
    print('Private overlay staged only. No token, DNS, connector or application changes applied.')
