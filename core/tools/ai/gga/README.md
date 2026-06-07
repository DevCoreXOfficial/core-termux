# Gentleman Guardian Angel

Provider-agnostic AI code review on every commit

**Package:** gga  
**Author:** Gentleman-Programming  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/Gentleman-Programming/gentleman-guardian-angel  
**Termux fork:** https://github.com/DevCoreXOfficial/gga-termux  
**Type:** AI code review CLI (Pure Bash)  
**License:** MIT

## Description

GGA (Gentleman Guardian Angel) is a provider-agnostic AI code review tool that runs on every commit. It validates staged files against your `AGENTS.md` rules using any LLM provider (Claude, Gemini, Codex, OpenCode, Ollama, LM Studio, GitHub Models). Pure Bash, zero dependencies, works as a standard pre-commit git hook.

The Termux fork adapts the installer/uninstaller for Android environments (Termux detects `$PREFIX` and installs to `$PREFIX/bin` and `$PREFIX/share/gga/lib`).

## Dependencies

- git, curl
- bash 5.0+

## Install

```bash
core install ai --gga
```

## Uninstall

```bash
core uninstall ai --gga
```

## Update

```bash
core update ai --gga
```

## Notes

- Source cloned to `$CORE_DATA/gga-termux/` (`~/.local/share/core-termux-data/gga-termux/`)
- Binary installed to `$PREFIX/bin/gga`
- Libraries installed to `$PREFIX/share/gga/lib/`
- Clones the Termux-compatible fork and runs its bundled `install.sh` / `uninstall.sh`
- Repository is updated via `git pull` on `core update ai --gga`
- Requires the gga repo to be present at runtime only during install/update (can be safely removed afterward)
