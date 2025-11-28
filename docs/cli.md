# CLI Design

This document describes:

1. The **current** CLI implemented in `scripts/mydbinstance.sh`
2. The **planned** unified `mydbin` CLI
3. A migration map from prototype → stable interface

---

## 1. Current prototype: `scripts/mydbinstance.sh`

The script uses a single entrypoint with long options:

| Action | Flag | Backed by functions |
|--------|-------|-----------------------|
| Initialize global config | `--initialize_config` | `initialize_config` |
| List instances | `--list` | `list_instances` |
| Create instance | `--create <name>` | `create_instance` |
| Destroy instance | `--destroy <name>` | `destroy_instance` |
| Initialize datadir (generic) | `--initialize <name>` | `initialize_instance` |
| Initialize MySQL 5.6 | `--initialize_56 <name>` | `initialize_instance_56` |
| Initialize MySQL 5.5 | `--initialize_55 <name>` | `initialize_instance_55` |
| Start instance | `--start <name>` | `start_instance` |
| Stop instance | `--stop <name>` | `stop_instance` |

Each action loads:

- `~/.mydbinstancerc` (global config)
- `~/.mydbinstancerc.d/<instance>rc` (instance config)
- `MYBINVERPATH` and `MYCNF` per instance

---

## 2. Planned final CLI: `mydbin`

The stable `mydbin` CLI will use subcommands, not flags:
mydbin  [options]
Core subcommands:

| Subcommand | Description |
|------------|-------------|
| `config init` | Initialize global configuration |
| `list` | List all DB instances |
| `init <version> <name>` | Create + initialize a new instance |
| `import <version> <name> --path <datadir>` | Import existing datadir |
| `start <name>` | Start instance |
| `stop <name>` | Stop instance |
| `destroy <name>` | Remove instance & data |
| `versions` | List installed server versions |
| `env list` | List project environments (future) |
| `env use <name>` | Activate instance for a project (future) |

This structure mirrors tools developers already know:
- `pyenv`
- `nvm`
- `rbenv`
- `kubectl`

---

## 3. Migration plan (prototype → `mydbin`)

| Prototype flag | New `mydbin` subcommand |
|----------------|--------------------------|
| `--initialize_config` | `mydbin config init` |
| `--list` | `mydbin list` |
| `--create` | `mydbin init` |
| `--initialize` | `mydbin init` (auto-detect version) |
| `--initialize_56` | `mydbin init --version 5.6` |
| `--initialize_55` | `mydbin init --version 5.5` |
| `--start` | `mydbin start` |
| `--stop` | `mydbin stop` |
| `--destroy` | `mydbin destroy` |

---

## 4. Implementation strategy

1. Keep `mydbinstance.sh` as **internal implementation logic**.
2. Introduce `bin/mydbin` (small wrapper script) that:
   - parses subcommands
   - maps them to prototype functions
3. Gradually migrate code into reusable shell libraries in `lib/`.

This ensures **zero breakage** while turning the prototype into a **real CLI tool**.
