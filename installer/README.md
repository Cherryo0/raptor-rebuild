# Installer

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
