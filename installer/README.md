# Installer

## One-liner (Mac)

Recommended — download it, read it, then run it (one line):

```bash
cd ~/ && curl -fsSL https://raw.githubusercontent.com/Cherryo0/raptor-rebuild/v1.1.0/installer/bootstrap.sh -o /tmp/raptor-bootstrap.sh && bash /tmp/raptor-bootstrap.sh
```

Add `less /tmp/raptor-bootstrap.sh` between the download and the run if you
want to read it first — it is short.

Do NOT use the `curl ... | bash </dev/tty` form: on macOS (zsh) the script
runs, but bash then stays waiting for terminal input after it finishes, so
the terminal looks stuck. Press Ctrl-C once to get your prompt back if that
happened — the install itself already finished. The download-then-run form
above exits cleanly.

The URL is pinned to v1.1.0 so it always fetches the exact tested file.
(The `main` branch link can briefly serve a stale copy from GitHub's file
cache right after a push — that is what happened on 2026-10-25, when a
just-fixed script was re-fetched as the old version.)

What the one-liner does: clones the public repo into `~/raptor-rebuild`,
then runs `installer/install.sh`. The `</dev/tty` part matters when piping —
it lets the installer ask you its confirmation question on your terminal
instead of reading from the pipe. Add `--dry-run` to preview, `--force` to
skip prompts: `... | bash -s -- --dry-run </dev/tty`.

Unlike the original line, this one never downloads a binary, never asks for
a licence key, and never touches your Roblox install. See
`docs/research/02-install-sh-analysis.md` for the comparison.

## `install.sh`

`install.sh` is a **safe rewrite** of the original v4.1 installer. It installs
only a launcher placeholder (`/Applications/Raptor.app`) and the scripts
directory (`~/Documents/RaptorUI/{AutoExecute,Dumped}`), plus a version file
in `~/Downloads/raptor-version.json`.

It does **not**: download any binary/dylib, patch Roblox, strip a code
signature, run an opaque binary, or fetch anything over HTTP. See
`docs/modules/02-installer.md` and `docs/research/02-install-sh-analysis.md`
for the original behaviour and the full comparison.

`quickfix.sh` verifies that install and re-creates missing directories.
Both scripts support `--dry-run` and `--help`.
