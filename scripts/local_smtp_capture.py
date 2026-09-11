#!/usr/bin/env python3
"""Loopback SMTP capture for synthetic manual tests; never relays or prints message contents."""
import argparse
import os
from pathlib import Path
import re
import socketserver
import uuid

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory", type=Path, required=True)
    parser.add_argument("--port", type=int, default=2526)
    parser.add_argument("--fail-file", type=Path, help="While this private file exists, reject DATA with SMTP 451")
    args = parser.parse_args()
    folder = args.directory.resolve()
    if folder.is_relative_to(ROOT):
        raise SystemExit("Capture must remain outside the repository.")
    folder.mkdir(parents=True, exist_ok=True)
    if os.name != "nt":
        folder.chmod(0o700)

    class Handler(socketserver.StreamRequestHandler):
        timeout = 15

        def reply(self, text):
            self.wfile.write((text + "\r\n").encode("ascii"))

        def handle(self):
            self.reply("220 localhost synthetic capture")
            recipient = False
            while raw := self.rfile.readline(8192):
                line = raw.decode("ascii", errors="replace").strip()
                verb = line.split(" ")[0].upper()
                if verb in {"EHLO", "HELO"}:
                    self.reply("250 localhost")
                elif verb == "MAIL":
                    recipient = False
                    self.reply("250 OK")
                elif verb == "RCPT":
                    recipient = bool(re.fullmatch(r"RCPT TO:<[^<>\s@]+@[^<>\s@]+\.(example|invalid)>", line, re.I))
                    self.reply("250 OK" if recipient else "550 Synthetic recipients only")
                elif verb == "DATA":
                    if not recipient:
                        self.reply("554 Recipient required")
                        continue
                    if args.fail_file and args.fail_file.exists():
                        self.reply("451 Synthetic delivery failure")
                        continue
                    self.reply("354 End with dot")
                    data = bytearray()
                    while chunk := self.rfile.readline(8192):
                        if chunk in {b".\r\n", b".\n"}:
                            break
                        data.extend(chunk[1:] if chunk.startswith(b"..") else chunk)
                        if len(data) > 1024 * 1024:
                            self.reply("552 Message too large")
                            return
                    else:
                        return
                    path = folder / (uuid.uuid4().hex + ".eml")
                    with path.open("xb") as output:
                        if os.name != "nt":
                            os.fchmod(output.fileno(), 0o600)
                        output.write(data)
                    self.reply("250 Captured locally")
                elif verb == "QUIT":
                    self.reply("221 Bye")
                    return
                elif verb in {"RSET", "NOOP"}:
                    recipient = False
                    self.reply("250 OK")
                else:
                    self.reply("502 Unsupported")

    class Server(socketserver.ThreadingTCPServer):
        daemon_threads = True

        def handle_error(self, request, client_address):
            # Broken test clients must not print SMTP payloads or exception details.
            pass

    with Server(("127.0.0.1", args.port), Handler) as server:
        print(f"Synthetic SMTP capture on 127.0.0.1:{args.port}; messages stay in the private directory.", flush=True)
        server.serve_forever()


if __name__ == "__main__":
    main()
