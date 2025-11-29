# mydbin

mydbin is a user-space sandbox for running multiple isolated MySQL and MariaDB
instances side-by-side without requiring root privileges. It is designed for
developers, DBAs and QA engineers who need fast, disposable database
environments for testing, debugging or CI pipelines.

Current implementation is a prototype Bash script:
`scripts/mydbinstance.sh` (marked EXPERIMENTAL / WIP). Future releases will
introduce a stable `mydbin` CLI with subcommands.

---

## Current capabilities (prototype)

- Stores configuration in the user’s home directory:
  - `~/.mydbinstancerc`
  - `~/.mydbinstancerc.d/<instance>rc`
- Supports multiple MySQL versions (5.5 → 8.4) via user-supplied binaries
- Provides lifecycle operations for isolated instances:
  - create
  - initialize (5.5 / 5.6 / 5.7+ variants)
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

```bash
chmod +x scripts/mydbinstance.sh

# First-time configuration
scripts/mydbinstance.sh --initialize_config
```
You will be asked for:
	•	instance root (default: ~/testdir)
	•	MySQL binaries location (default: /opt/mysqlbin)
```
# List all instances
scripts/mydbinstance.sh --list

# Create a new instance
scripts/mydbinstance.sh --create <name>

# Initialize data directory (>=5.7)
scripts/mydbinstance.sh --initialize <name>

# Initialize for old specific versions
scripts/mydbinstance.sh --initialize_55 <name>
scripts/mydbinstance.sh --initialize_56 <name>

# Start / stop
scripts/mydbinstance.sh --start <name>
scripts/mydbinstance.sh --stop <name>

# Destroy (remove data + rc)
scripts/mydbinstance.sh --destroy <name>
```
