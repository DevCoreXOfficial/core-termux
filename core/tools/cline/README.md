# Cline CLI

The open source coding agent in your IDE and terminal.

**Website:** https://cline.bot  
**Repository:** https://github.com/cline/cline  
**License:** Apache-2.0

## Description

Autonomous coding agent as an SDK, IDE extension, or CLI assistant. Run Cline in your terminal. Interactive chat or fully headless for CI/CD and scripting. Terminal UI, headless mode, shell commands, and CLI-specific flows.

## Installation

```bash
core install ai --cline
```

## Usage

```bash
cline --help
```

## Commands

| Command             | Description                              |
|---------------------|------------------------------------------|
| `core install ai --cline`   | Install Cline CLI                        |
| `core uninstall ai --cline` | Uninstall Cline CLI                      |
| `core update ai --cline`    | Update Cline CLI to latest version       |
| `core reinstall ai --cline` | Reinstall Cline CLI                      |
| `core show ai --cline`      | Show this help                           |

## Installation Methods

### glibc + proot (recommended)
Downloads the prebuilt ARM64 binary from npm registry, patches its ELF interpreter to the Termux glibc loader, and runs it under proot with `/lib` and `/bin` bound. The `/bin` bind is required because Cline's `run_commands` hardcodes `spawn('/bin/bash', ['-c', cmd])` and Termux has no `/bin/bash` natively.

### Proot-distro (alternative)
Installs inside an Ubuntu container using proot-distro for maximum compatibility.
