"""Raptor API client prototype (clean-room).

Mirrors the original's version + licence protocol shape WITHOUT its flaws:
- HTTPS only (plain HTTP is refused).
- Licence keys are never put in a URL query string. They are read from the
  RAPTOR_LICENSE_KEY environment variable or stdin, and sent via POST with
  an Authorization header.
- The live licence/whitelist endpoints are stubs here: activate() and
  check_whitelist() raise NotImplementedError unless a real HTTPS base URL
  is explicitly configured AND the caller opts in. Version fetch is the
  only live call, and it is covered by mocked tests.

No binary is downloaded by this module. No HWID is exfiltrated: the local
device id is computed locally and only included in a POST body when the
caller explicitly enables it.
"""
from __future__ import annotations

import hashlib
import json
import os
import platform
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass


class RaptorApiError(Exception):
    """Base error for the API client."""


class NotImplementedLiveCall(RaptorApiError):
    """Raised when a live endpoint is intentionally not implemented."""


@dataclass
class VersionInfo:
    channel: str
    client_version_upload: str
    version: str | None = None


def local_device_id() -> str:
    """Local-only device identifier (display purposes). Never uploaded by default."""
    raw = f"{platform.node()}|{platform.machine()}|{platform.system()}"
    return "local-" + hashlib.sha256(raw.encode()).hexdigest()[:16]


def read_key_from_env_or_stdin() -> str:
    """Read a licence key from env or stdin. Never from argv (argv leaks to ps)."""
    key = os.environ.get("RAPTOR_LICENSE_KEY", "").strip()
    if key:
        return key
    if not sys.stdin.isatty():
        return sys.stdin.read().strip()
    return ""


class RaptorApiClient:
    def __init__(self, base_url: str | None = None, timeout: float = 10.0):
        if base_url is not None and not base_url.startswith("https://"):
            raise RaptorApiError("base_url must use HTTPS")
        self.base_url = (base_url or "").rstrip("/")
        self.timeout = timeout

    def _get_json(self, path: str) -> dict:
        if not self.base_url:
            raise NotImplementedLiveCall("No live base URL configured; version fetch is a stub.")
        url = f"{self.base_url}{path}"
        request = urllib.request.Request(url, method="GET", headers={"Accept": "application/json"})
        try:
            with urllib.request.urlopen(request, timeout=self.timeout) as response:
                return json.loads(response.read().decode("utf-8"))
        except urllib.error.HTTPError as exc:
            raise RaptorApiError(f"HTTP {exc.code} fetching {path}") from exc
        except urllib.error.URLError as exc:
            raise RaptorApiError(f"Network error fetching {path}: {exc.reason}") from exc

    def fetch_version(self) -> VersionInfo:
        """Fetch version.json. Shape mirrors the original's channel/clientVersionUpload fields."""
        data = self._get_json("/main/version.json")
        return VersionInfo(
            channel=str(data.get("channel", "")),
            client_version_upload=str(data.get("clientVersionUpload", "")),
            version=data.get("version"),
        )

    def check_whitelist(self, hwid: str | None = None) -> bool:
        """Whitelist check — STUB. The original sent HWID in a GET query; this rebuild does not."""
        raise NotImplementedLiveCall(
            "Whitelist check is not implemented: no HWID is exfiltrated by this rebuild."
        )

    def activate(self, key: str) -> str:
        """Sellix activation — STUB. The original sent ?key=&hwid= in GET; this rebuild does not."""
        if not key or any(ch.isspace() for ch in key):
            raise RaptorApiError("Invalid key format.")
        raise NotImplementedLiveCall(
            "Live activation is not implemented in this clean-room stub. "
            "A real implementation must POST the key via an Authorization header."
        )

    def activation_request(self, key: str) -> urllib.request.Request:
        """Build (do not send) the safe POST activation request shape for review."""
        if not self.base_url:
            raise RaptorApiError("No base URL configured.")
        payload = json.dumps({"hwid": local_device_id()}).encode()
        return urllib.request.Request(
            f"{self.base_url}/sellix",
            data=payload,
            method="POST",
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {key}"},
        )


def main(argv: list[str] | None = None) -> int:
    args = list(argv if argv is not None else sys.argv[1:])
    base = os.environ.get("RAPTOR_API_BASE", "")
    client = RaptorApiClient(base_url=base or None)
    if not args or args[0] in {"-h", "--help"}:
        print("Usage: raptor_api.py version | activate")
        print("  version   Fetch version.json (needs RAPTOR_API_BASE=https://...)")
        print("  activate  Read key from RAPTOR_LICENSE_KEY or stdin (stub: raises NotImplemented)")
        return 0
    if args[0] == "version":
        try:
            print(client.fetch_version())
        except RaptorApiError as exc:
            print(f"Error: {exc}", file=sys.stderr)
            return 1
        return 0
    if args[0] == "activate":
        key = read_key_from_env_or_stdin()
        try:
            print(client.activate(key))
        except RaptorApiError as exc:
            print(f"Error: {exc}", file=sys.stderr)
            return 1
        return 0
    print(f"Unknown command: {args[0]}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
