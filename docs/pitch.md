# mydbin — Product Pitch

## Overview
mydbin is a rootless MySQL/MariaDB sandbox enabling developers and QA teams to
create fast, isolated, disposable database instances across multiple versions.
It removes the need for Docker, VMs, root privileges, or manual installations.

---

## Problem
Teams frequently face:
- Inability to run multiple DB versions locally
- Corporate restrictions blocking Docker or root access
- Slow debugging of production issues
- Inconsistent local vs CI test environments
- Heavy manual setup for MySQL/MariaDB testing

The result: slow development, difficult bug reproduction, and limited testing.

---

## Solution
mydbin provides:
- fully isolated per-instance directories (data, logs, socket, PID)
- one-command lifecycle management
- multi-version support (5.5 → 8.4 / MariaDB 10.x → 11.x)
- pure user-space operation (no root, no containers)
- reproducible environments suitable for CI

---

## Why now
- MySQL 8.4 LTS and MariaDB 11.x create new compatibility challenges
- Enterprises increasingly restrict Docker and local admin rights
- Developer toolchains are shifting toward lightweight, portable solutions
- CI/CD pipelines need deterministic databases for automated testing

---

## Users
- Developers building against MySQL/MariaDB
- DBAs performing repro and upgrade tests
- QA teams running cross-version regression suites
- CI pipeline maintainers needing ephemeral databases

---

## Competitive Edge
Unlike Docker images or VMs, mydbin is:
- rootless
- lightweight
- version-flexible
- predictable
- easy to embed into scripts

It fills a gap in developer tooling: **no existing tool provides “pyenv-style” DB sandboxes.**

---

## Traction & Roadmap
**Prototype:**  
`scripts/mydbinstance.sh` implements full instance lifecycle.

**Next milestones:**
- v0.1: Document and harden current script  
- v0.2: Introduce `mydbin` front-end CLI  
- v0.3: Version manager  
- v0.4: Environments  
- v0.5: CI-ready usage  
- v1.0: Stable CLI contract  

---

## Long-term potential
- Verified binary distribution  
- Developer experience enhancements  
- Team collaboration features  
- Enterprise policies and audit  
- Commercial support  

mydbin begins as a small, powerful CLI and grows into a full developer platform.
