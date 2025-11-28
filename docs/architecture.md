# Architecture Overview

This document describes the architecture of the current prototype script
(`scripts/mydbinstance.sh`) and the planned structure for the `mydbin` CLI.

---

## 1. Current architecture (prototype)

The project consists of:

- **One main script**: `scripts/mydbinstance.sh`
- **One global config file**: `~/.mydbinstancerc`
- **One directory containing per-instance rc files**:
  `~/.mydbinstancerc.d/<instance>rc`

### Directory layout created via `--initialize_config`
~/.mydbinstancerc
~/.mydbinstancerc.d/
~/testdir//        # default path unless overridden
data/
binlogs/
tmp/
.cnf
.pid
.sock
-err.log
-slow.log
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
The user chooses the version interactively when creating an instance.

- **Lifecycle functions**
- `create_instance`
- `initialize_instance`, `_56`, `_55`
- `start_instance`
- `stop_instance`
- `destroy_instance`
- `list_instances`

---

## 2. Planned architecture (mydbin)

The project will transition to a multi-file layout:- **Version selection**  
  The script uses a fixed array:
  The user chooses the version interactively when creating an instance.

- **Lifecycle functions**
- `create_instance`
- `initialize_instance`, `_56`, `_55`
- `start_instance`
- `stop_instance`
- `destroy_instance`
- `list_instances`

---

## 2. Planned architecture (mydbin)

The project will transition to a multi-file layout:
bin/mydbin                    # User-facing CLI
scripts/mydbinstance.sh       # Low-level implementation
lib/instances.sh              # Core lifecycle logic (future)
lib/versions.sh               # Version detection / management (future)
docs/                         # Documentation
### mydbin (planned)
- Parses subcommands (e.g. `mydbin start <name>`).
- Calls into implementation functions.
- Outputs predictable, CI-friendly messages.

### scripts/mydbinstance.sh (current → internal)
- Contains all shell logic today.
- Gradually becomes internal plumbing behind cleaner APIs.

### Future: `lib/` directory
Split responsibilities:

- `instances.sh`  
  create/init/start/stop/destroy logic  

- `versions.sh`  
  version detection, version installation, future downloads  

### State storage (future)
Move from loose rc files to structured instance metadata:
/instance.json
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
