# Module 04 — API Client + Versioning

| Field | Value |
|---|---|
| Status | Implemented — Python prototype, mocked tests |
| Owner area | api-client/ |
| Related research | docs/research/02-install-sh-analysis.md, 03-reverse-skill-methodology.md (R21) |

## Purpose
Prototype the version/licence protocol (version.json shape, channel/clientVersionUpload) in testable Python, without live network in tests.

## Public behaviour observed
Original fetches api.macsploit.dev/main/version.json and reads channel + clientVersionUpload to pin a RobloxPlayer.zip (preview vs stable, arm64 vs Intel).

## Clean-room design
RaptorApiClient (stdlib urllib only): base_url must be https://; fetch_version() GETs /main/version.json -> VersionInfo(channel, client_version_upload, version?). check_whitelist() and activate() are stubs raising NotImplementedLiveCall. _get_json maps HTTPError/URLError to RaptorApiError. CLI: raptor_api.py version | activate, base from RAPTOR_API_BASE, key from env/stdin.

## Public API / types
```
VersionInfo(channel: str, client_version_upload: str, version: str | None)
RaptorApiClient(base_url, timeout=10.0)
.fetch_version() -> VersionInfo
.check_whitelist(hwid=None) -> raises NotImplementedLiveCall
.activate(key) -> raises NotImplementedLiveCall / RaptorApiError
.activation_request(key) -> urllib Request (POST, Bearer)
local_device_id(); read_key_from_env_or_stdin()
```

## Data flow
1. Client constructed with HTTPS base (else RaptorApiError). 2. fetch_version GETs /main/version.json. 3. JSON decoded to VersionInfo. 4. Caller compares with current version (UpdaterService in Swift mirrors this).

## Files
api-client/raptor_api.py; api-client/requirements.txt; api-client/README.md; api-client/tests/test_api_client.py

## Config
RAPTOR_API_BASE (https only); RAPTOR_LICENSE_KEY; timeout 10s default.

## Edge cases
HTTP base -> rejected at construction. No base -> NotImplementedLiveCall (not a network attempt). Missing version field -> version=None, client_version_upload used as fallback. Non-JSON -> decoding error surfaced.

## Security notes
HTTPS only. No secrets in URLs. No binary download. No HWID upload. Tests use mocked urlopen — zero live network.

## Tests
pytest (7 tests): stable local id, HTTP rejected, mocked version fetch, no-base stub, bad-key rejection, whitelist stub, POST+header shape with no key in URL.

## Open questions
Real version.json schema beyond channel/clientVersionUpload? Rate limits / auth on the real endpoint? Should the Swift ApiClient share a spec file with this prototype?
