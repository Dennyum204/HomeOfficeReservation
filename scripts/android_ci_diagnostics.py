#!/usr/bin/env python3
"""Bounded, read-only CI transport/resource evidence; never capture app logs/tokens."""
import argparse
import datetime
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time


def receive(connection, size):
    data = b""
    while len(data) < size:
        part = connection.recv(size - len(data))
        if not part:
            raise OSError("ADB response ended")
        data += part
    return data


def transport_state():
    # Query an existing server directly. Unlike invoking adb, this cannot start
    # or restart the server and accidentally hide the original disconnect.
    try:
        with socket.create_connection(("127.0.0.1", 5037), timeout=1) as connection:
            connection.sendall(b"000chost:devices")
            if receive(connection, 4) != b"OKAY":
                return "server_rejected_query"
            size = int(receive(connection, 4), 16)
            if size > 65536:
                return "invalid_response"
            rows = receive(connection, size).decode("ascii", errors="replace").splitlines()
            for row in rows:
                fields = row.split()
                if len(fields) == 2 and fields[0] == "emulator-5554":
                    return fields[1] if fields[1] in {"device", "offline", "unauthorized"} else "other"
            return "emulator_absent"
    except (OSError, ValueError):
        return "server_unavailable"


def counters(path, allowed):
    result = {}
    try:
        for row in Path(path).read_text().splitlines():
            fields = row.replace(":", "").split()
            if len(fields) >= 2 and fields[0] in allowed:
                result[fields[0]] = int(fields[1])
    except (OSError, ValueError):
        pass
    return result


def snapshot():
    processes = []
    for path in Path("/proc").glob("[0-9]*"):
        try:
            name = (path / "comm").read_text().strip()
            if name != "adb" and not name.startswith(("qemu-system", "emulator")):
                continue
            processes.append({"pid": int(path.name), "kind": "adb" if name == "adb" else "emulator",
                              **counters(path / "status", {"VmRSS", "VmHWM", "Threads"})})
        except OSError:
            continue
    return {
        "utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "transport": transport_state(),
        "host_kib": counters("/proc/meminfo", {"MemAvailable", "SwapTotal", "SwapFree"}),
        "host_counters": counters("/proc/vmstat", {"pswpin", "pswpout", "oom_kill"}),
        "cgroup_events": counters("/sys/fs/cgroup/memory.events", {"low", "high", "max", "oom", "oom_kill"}),
        "load": list(os.getloadavg()),
        "processes": processes,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--start", action="store_true")
    args = parser.parse_args()
    if sys.platform != "linux" or os.environ.get("GITHUB_ACTIONS") != "true":
        parser.error("Restricted to disposable Linux GitHub CI; not local emulators or Pi")
    output = Path(os.environ["RUNNER_TEMP"]) / "android-transport.jsonl"
    if args.start:
        # Only one monitor per job. Exclusive creation prevents duplicated sampling.
        with output.open("x", encoding="utf-8") as receipt:
            receipt.write(json.dumps({"diagnostic_only": True, "seconds": 1500, "interval": 5}) + "\n")
        subprocess.Popen([sys.executable, str(Path(__file__).resolve())], stdin=subprocess.DEVNULL,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
        print("Read-only ADB/resource sampling started; no logs, payloads, retries or server restarts.")
        return
    deadline = time.monotonic() + 1500
    with output.open("a", encoding="utf-8") as receipt:
        while time.monotonic() < deadline:
            receipt.write(json.dumps(snapshot()) + "\n")
            receipt.flush()
            time.sleep(5)


if __name__ == "__main__":
    main()
