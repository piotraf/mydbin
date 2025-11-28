# Roadmap

This roadmap reflects the actual state of `scripts/mydbinstance.sh` and the
planned evolution toward a mature `mydbin` CLI.

---

## v0.1 — Prototype hardening (current cycle)
- Document existing behavior (`README.md`, `docs/cli.md`)
- Ensure consistent exit codes
- Improve error messages
- Verify instance directory and path handling
- Minor refactors inside the script without breaking behavior
- Tag this as the first public prototype

---

## v0.2 — Introduce `mydbin` CLI front-end
- Add `bin/mydbin` wrapper
- Map subcommands to current flags
- Keep all logic in `scripts/mydbinstance.sh`
- Provide unified help output (`mydbin help`)
- Zero breaking changes

---

## v0.3 — Version manager
- Standardize version paths under `~/.mydbin/versions`
- Allow “registering” installed MySQL/MariaDB
- Add `mydbin versions`  
- Optional future: download verified binaries (opt-in)

---

## v0.4 — Environment features
- Project-local config: `.mydbin-env`
- Commands:
  - `mydbin env use <instance>`
  - `mydbin env list`
- Improve metadata tracking (instance.json)

---

## v0.5 — CI-ready design
- Non-interactive initialization
- Machine-friendly output (`--json` future)
- Health checks before `start`
- Provide GitHub Actions / GitLab CI examples

---

## v1.0 — Stable API
- Finalized subcommand set
- Backward compatibility guarantee within 1.x
- Polished documentation
- Optional lightweight binary distribution tool

---

## Long-term ideas
- Snapshot / restore
- Instance cloning
- Minimal admin UI
- Remote datasets (future commercial features)
