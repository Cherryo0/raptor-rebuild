# api-client — Python prototype

Mirrors the original's version + licence protocol shape without its flaws:
HTTPS only, keys via env/stdin and POST + `Authorization` header, never in a
URL query string, no HWID exfiltration, no binary download.

```bash
python3 -m pip install -r requirements.txt
python3 -m pytest tests/ -q
RAPTOR_API_BASE=https://api.example.invalid python3 raptor_api.py version
RAPTOR_LICENSE_KEY='<key>' python3 raptor_api.py activate   # stub: NotImplemented
```

See `docs/modules/04-api-client-versioning.md` and
`docs/modules/03-licensing-sellix-hwid.md`.
