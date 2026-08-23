## Package Information

- **Name:** Cline CLI
- **Tags:** ai, agent, coding
- **Project:** https://cline.bot
- **Dependencies:** nodejs

## What is it?

The open source coding agent in your IDE and terminal.

**Website:** https://cline.bot  
**Repository:** https://github.com/cline/cline  
**License:** Apache-2.0

### Description

Autonomous coding agent as an SDK, IDE extension, or CLI assistant. Run Cline in your terminal. Interactive chat or fully headless for CI/CD and scripting. Terminal UI, headless mode, shell commands, and CLI-specific flows.

### Installation

```bash
core install cline
```

### Usage

```bash
cline --help
```

### Commands

| Command             | Description                              |
|---------------------|------------------------------------------|
| `core install cline`   | Install Cline CLI                        |
| `core uninstall cline` | Uninstall Cline CLI                      |
| `core update cline`    | Update Cline CLI to latest version       |
| `core reinstall cline` | Reinstall Cline CLI                      |
| `core show cline`      | Show this help                           |

### Installation Methods

#### glibc + proot (recommended)
Downloads the prebuilt ARM64 binary from npm registry, patches its ELF interpreter to the Termux glibc loader, and runs it under proot with `/lib` and `/bin` bound. The `/bin` bind is required because Cline's `run_commands` hardcodes `spawn('/bin/bash', ['-c', cmd])` and Termux has no `/bin/bash` natively.

#### Proot-distro (alternative)
Installs inside an Ubuntu container using proot-distro for maximum compatibility.

## How to use it?

```bash
core install cline      # install
core update cline       # update
core uninstall cline    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show cline:es`.
