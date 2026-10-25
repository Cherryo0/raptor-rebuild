# Module 03 — Licensing — Sellix + HWID

| Field | Value |
|---|---|
| Status | Stub — live activation not implemented |
| Owner area | App/Services/LicensingService.swift, api-client/ |
| Related research | docs/research/02-install-sh-analysis.md, 04-malware-trust-check.md |

## Purpose
Model licence activation (Sellix key + HWID) safely, without the original's secret-in-GET and HWID-exfiltration flaws.

## Public behaviour observed
Original: GET api/sellix?key=<key>&hwid=<hwid> must return exactly 'Key Activation Complete!'; GET api/whitelist?hwid=<hwid> gates install. Monthly $3.00/mo verified.

## Clean-room design
LicensingService validates key format locally (non-empty, no whitespace, 8+ chars), then delegates to ApiClient, which throws .notImplemented for the live call. ApiClient.licenceActivationRequest builds a POST with Authorization: Bearer <key> and a JSON body — for review only, never sent in the stub. Python prototype mirrors this (POST + header, key from env/stdin). HWID: localDeviceIdentifier() is computed locally for display only and never uploaded.

## Public API / types
```
LicensingService.isPlausibleKey(_) -> Bool
LicensingService.activate(key:) async throws -> LicenceState
LicensingService.localDeviceIdentifier() -> String
LicensingError: invalidKeyFormat | notImplemented | network | server
RaptorApiClient.activate(key:) -> raises NotImplementedLiveCall
RaptorApiClient.activation_request(key:) -> POST Request (unsent)
```

## Data flow
1. User enters key in LicensingView (SecureField, memory only). 2. isPlausibleKey. 3. activate — ApiClient stub throws .notImplemented. 4. UI shows the reason; licenceState = .notImplemented.

## Files
App/Services/LicensingService.swift; App/Views/LicensingView.swift; App/Services/ApiClient.swift; api-client/raptor_api.py

## Config
No live base URL configured. RAPTOR_LICENSE_KEY env var (Python client). No key is persisted in this skeleton.

## Edge cases
Key with whitespace -> invalidKeyFormat. Empty key -> invalidKeyFormat. No network -> stub error, not a fake success. Key must never appear in logs, URLs, or argv.

## Security notes
Secrets never in GET query, argv, or logs. HWID never exfiltrated. Original GET activation is documented as a flaw, not reproduced.

## Tests
pytest: bad key rejected; valid key raises NotImplementedLiveCall; activation request is POST, URL contains no key, Authorization header is Bearer. Swift: format validation unit tests (planned).

## Open questions
Keychain storage for the key? Sellix API shape (unverified — needs a real endpoint spec)? HWID definition (original hwid binary is opaque and untrusted)?
