# OpenCode

AI coding agent that runs natively in Termux with glibc support

## Install

```bash
core install ai --opencode
```

You will be prompted to choose:

1. **Native (recommended)** — Compiles a glibc bootstrapper and downloads the latest OpenCode binary from GitHub releases
2. **Proot-distro (alternative)** — Runs OpenCode inside an Ubuntu proot-distro container

## Uninstall

```bash
core uninstall ai --opencode
```

## Update

```bash
core update ai --opencode
```

## Notes

- **Native mode** requires `glibc-repo`, `glibc`, `clang`, and other dependencies (installed automatically)
- The native binary is stored in `~/.local/share/core-termux-data/opencode/`
- A small C bootstrapper (`opencode_helper.c`) handles ELF loading via the glibc dynamic linker
- **Proot mode** uses `proot-distro ubuntu` and installs via the official opencode.ai installer
