# Antigravity CLI

AI coding agent that runs natively in Termux with glibc support

## Install

```bash
core install ai --antigravity-cli
```

## Uninstall

```bash
core uninstall ai --antigravity-cli
```

## Update

```bash
core update ai --antigravity-cli
```

## Notes

- Requires `glibc-repo`, `glibc`, `clang`, `python`, `jq`, `curl`, `tar` (installed automatically)
- The patched binary is stored in `~/.local/share/core-termux-data/antigravity-cli/`
- VA39 bit patches are applied via Python to the upstream binary before installation
- A small C bootstrapper (`agy_helper.c`) handles ELF loading via the glibc dynamic linker
