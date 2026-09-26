#!/usr/bin/env python3
"""Minimal Prometheus exporter for Transmission's RPC (standard library only).

Transmission runs inside its own network namespace and its RPC needs
authentication, so we query it here and re-expose a small set of gauges on
loopback for VictoriaMetrics to scrape.
"""

import base64
import json
import os
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, HTTPServer

RPC_URL = os.environ.get(
    "TRANSMISSION_RPC_URL", "http://127.0.0.1:9091/transmission/rpc"
)
RPC_USER = os.environ.get("TRANSMISSION_RPC_USER", "admin")
LISTEN = os.environ.get("TRANSMISSION_EXPORTER_LISTEN", "127.0.0.1:9555")

STATUS = {
    0: "stopped",
    1: "check-wait",
    2: "checking",
    3: "download-wait",
    4: "downloading",
    5: "seed-wait",
    6: "seeding",
}


def _password():
    directory = os.environ.get("CREDENTIALS_DIRECTORY")
    if directory:
        path = os.path.join(directory, "transmission-rpc")
        if os.path.exists(path):
            with open(path, encoding="utf-8") as handle:
                data = json.load(handle)
            for key in ("rpc-password", "password"):
                if data.get(key):
                    return data[key]
    path = os.environ.get("TRANSMISSION_RPC_PASSWORD_FILE")
    if path:
        with open(path, encoding="utf-8") as handle:
            return handle.read().strip()
    return os.environ.get("TRANSMISSION_RPC_PASSWORD", "")


_AUTH = "Basic " + base64.b64encode(
    f"{RPC_USER}:{_password()}".encode()
).decode()
_SESSION = [""]


def rpc(method, arguments=None):
    payload = json.dumps({"method": method, "arguments": arguments or {}}).encode()
    request = urllib.request.Request(
        RPC_URL,
        data=payload,
        headers={
            "Authorization": _AUTH,
            "Content-Type": "application/json",
            "X-Transmission-Session-Id": _SESSION[0],
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            return json.load(response)["arguments"]
    except urllib.error.HTTPError as error:
        if error.code == 409:
            _SESSION[0] = error.headers.get("X-Transmission-Session-Id", "")
            return rpc(method, arguments)
        raise


def _escape(value):
    return (
        str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ")
    )


def _collect():
    try:
        torrents = rpc(
            "torrent-get",
            {
                "fields": [
                    "name",
                    "hashString",
                    "status",
                    "rateUpload",
                    "rateDownload",
                    "peersConnected",
                    "uploadRatio",
                    "percentDone",
                    "trackerStats",
                ]
            },
        )["torrents"]
        session = rpc("session-stats")
    except Exception as error:  # noqa: BLE001 - report any failure as down
        return f"# HELP transmission_up 1 if the RPC was reachable.\n# TYPE transmission_up gauge\ntransmission_up 0\n# scrape_error {_escape(error)}\n"

    out = [
        "# HELP transmission_up 1 if the RPC was reachable.",
        "# TYPE transmission_up gauge",
        "transmission_up 1",
        "# HELP transmission_upload_rate_bytes_per_second Session upload rate.",
        "# TYPE transmission_upload_rate_bytes_per_second gauge",
        f"transmission_upload_rate_bytes_per_second {session.get('uploadRate', 0)}",
        "# HELP transmission_download_rate_bytes_per_second Session download rate.",
        "# TYPE transmission_download_rate_bytes_per_second gauge",
        f"transmission_download_rate_bytes_per_second {session.get('downloadRate', 0)}",
    ]

    states = {}
    for tor in torrents:
        labels = (
            f'{{name="{_escape(tor["name"])}",'
            f'turbohash="{tor["hashString"]}"}}'
        )
        out.append(
            f"transmission_torrent_upload_rate_bytes_per_second{labels} "
            f"{tor['rateUpload']}"
        )
        out.append(
            f"transmission_torrent_download_rate_bytes_per_second{labels} "
            f"{tor['rateDownload']}"
        )
        out.append(
            f"transmission_torrent_peers_connected{labels} {tor['peersConnected']}"
        )
        out.append(
            f"transmission_torrent_upload_ratio{labels} {tor['uploadRatio']}"
        )
        out.append(
            f"transmission_torrent_percent_done{labels} {tor['percentDone']}"
        )
        state = STATUS.get(tor["status"], str(tor["status"]))
        states[state] = states.get(state, 0) + 1
        trackers = tor.get("trackerStats") or []
        if trackers:
            ok = 1 if trackers[0].get("lastAnnounceSucceeded") else 0
            out.append(
                f"transmission_torrent_tracker_announce_ok{labels} {ok}"
            )

    out.append("# HELP transmission_torrents Number of torrents by state.")
    out.append("# TYPE transmission_torrents gauge")
    for state, count in sorted(states.items()):
        out.append(f'transmission_torrents{{state="{state}"}} {count}')

    return "\n".join(out) + "\n"


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802 - http.server API
        if self.path != "/metrics":
            self.send_response(404)
            self.end_headers()
            return
        body = _collect().encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *_args):
        pass


def main():
    host, port = LISTEN.rsplit(":", 1)
    HTTPServer((host, int(port)), Handler).serve_forever()


if __name__ == "__main__":
    main()
