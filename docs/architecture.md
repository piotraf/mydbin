# Architecture Overview

This document describes the architecture of the current prototype script
(`scripts/mydbin.sh`) and the planned structure for the `mydbin` CLI.

---

## 1. Current architecture (prototype)

The project currently consists of:

- **One main script**: `scripts/mydbin.sh`
- **One global config file**: `~/.mydbinrc`
- **One directory containing per-instance rc files**:
  `~/.mydbinrc.d/<instance>rc`

### Directory layout created via `--initialize_config`

```text
~/.mydbinrc
~/.mydbinrc.d/
~/testdir/               # default instance root unless overridden
└── <instance>/
    ├── data/
    ├── binlogs/
    ├── tmp/
    ├── <instance>.cnf
    ├── <instance>.pid
    ├── <instance>.sock
    ├── <instance>-err.log
    └── <instance>-slow.log
```

### Key concepts

- **User-space only**
  Everything runs under the normal OS user. No root required.

- **Per-instance isolation**
  Each instance has:
  - its own datadir
  - its own socket
  - its own PID file
  - its own log files
  - a unique MySQL configuration file

- **Version selection**
  The script uses a fixed `MYSQL_VERSIONS` array, and the user chooses the
  version interactively when creating an instance.

- **Lifecycle functions**
  - `create_instance`
  - `initialize_instance`, `initialize_instance_56`, `initialize_instance_55`
  - `start_instance`
  - `stop_instance`
  - `destroy_instance`
  - `list_instances`

---

## 2. Planned architecture (`mydbin`)

The project will transition toward a cleaner multi-file layout:

```text
bin/mydbin              # future user-facing CLI
scripts/mydbin.sh       # current prototype implementation
lib/instances.sh        # core lifecycle logic (future)
lib/versions.sh         # version detection / management (future)
docs/                   # documentation
```

### `mydbin` planned CLI

- Parses subcommands, for example `mydbin start <name>`.
- Calls into implementation functions.
- Outputs predictable, CI-friendly messages.

### `scripts/mydbin.sh` current prototype

- Contains all shell logic today.
- Gradually becomes internal plumbing behind cleaner APIs.

### Future `lib/` directory

Split responsibilities:

- `instances.sh`
  create/init/start/stop/destroy logic

- `versions.sh`
  version detection, version installation, future downloads

### State storage (future)

Move from loose rc files to structured instance metadata:

```text
<instance>/instance.json
```

This will enable richer features:
- env switching
- robust recovery
- metadata for CI

---

## 3. Principles

- **Zero root** (always)
- **Predictable CLI**
- **Portable**, works on developer laptops and CI servers
- **Multi-version** compatible
- **Lightweight** – no binaries, no Docker dependencies

The architecture supports a small MVP now and a scalable tool later.
