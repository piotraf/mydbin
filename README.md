# mydbin

mydbin is a user-space sandbox for running multiple isolated MySQL and MariaDB
instances side-by-side without root privileges. It is designed for developers,
DBAs and QA engineers who need fast, disposable database environments for
testing, debugging or CI pipelines.

The tool creates a full instance directory layout (datadir, binlogs, tmp,
socket, PID, logs, and a dedicated my.cnf). You can either initialize a fresh
empty database or import an existing datadir. Once created, each instance can be
started, stopped and destroyed independently, with all state stored under the
user’s home directory.

Current implementation is a prototype Bash script:
`scripts/mydbin.sh` (marked EXPERIMENTAL / WIP). Future releases will
introduce a stable `mydbin` CLI with subcommands.

---

## Current capabilities (prototype)

- Stores configuration in the user’s home directory:
  - `~/.mydbinrc`
  - `~/.mydbinrc.d/<instance>rc`
- Supports multiple MySQL versions (5.5 → 9.7) via user-supplied binaries
- Provides lifecycle operations for isolated instances:
  - create
  - initialize (5.5 / 5.6 / 5.7 / 8.0 / 8.4 LTS / 9.7 LTS variants)
  - start
  - stop
  - destroy
  - list

Each instance has its own:
- datadir
- binlogs
- socket
- pid file
- temporary directory
- configuration file

---

## Quick start

### Obtain the current script

Download the current development version from `main`:

```bash
curl -fL -o mydbin.sh https://raw.githubusercontent.com/piotraf/mydbin/main/scripts/mydbin.sh
```

```bash
wget -O mydbin.sh https://raw.githubusercontent.com/piotraf/mydbin/main/scripts/mydbin.sh
```

Download a tag-pinned version:

```bash
curl -fL -o mydbin.sh https://raw.githubusercontent.com/piotraf/mydbin/<tag>/scripts/mydbin.sh
```

```bash
wget -O mydbin.sh https://raw.githubusercontent.com/piotraf/mydbin/<tag>/scripts/mydbin.sh
```

Clone the repository instead:

```bash
git clone https://github.com/piotraf/mydbin.git
cd mydbin
```

### Initialize local configuration

```bash
chmod +x mydbin.sh

# First-time configuration
./mydbin.sh --initialize_config
```

You will be asked for:
- instance root (default: `~/testdir`)
- MySQL binaries location (default: `/opt/mysqlbin`)

```bash
# List all instances
./mydbin.sh --list

# Create a new instance
./mydbin.sh --create <name>

# Initialize data directory (>=5.7)
./mydbin.sh --initialize <name>

# Initialize for old specific versions
./mydbin.sh --initialize_55 <name>
./mydbin.sh --initialize_56 <name>

# Start / stop
./mydbin.sh --start <name>
./mydbin.sh --stop <name>

# Destroy (remove data + rc)
./mydbin.sh --destroy <name>
```

When using a cloned repository directly, run `scripts/mydbin.sh` instead of `./mydbin.sh`.
