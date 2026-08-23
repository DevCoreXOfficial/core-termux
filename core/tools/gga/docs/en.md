## Package Information

- **Name:** Gentleman Guardian Angel
- **Tags:** ai, code-review
- **Dependencies:** None required by Core

## What is it?

Provider-agnostic AI code review on every commit

**Package:** gga  
**Author:** Gentleman-Programming  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/Gentleman-Programming/gentleman-guardian-angel  
**Type:** AI code review CLI (Pure Bash)  
**License:** MIT

### Description

GGA (Gentleman Guardian Angel) is a provider-agnostic AI code review tool that runs on every commit. It validates staged files against your `AGENTS.md` rules using any LLM provider (Claude, Gemini, Codex, OpenCode, Ollama, LM Studio, GitHub Models). Pure Bash, zero dependencies, works as a standard pre-commit git hook.

Clones the upstream repo and applies Termux patches for Android support (`$PREFIX/bin` and `$PREFIX/share/gga/lib`).

### Dependencies

- git, curl
- bash 5.0+

### Install

```bash
core install gga
```

### Uninstall

```bash
core uninstall gga
```

### Update

```bash
core update gga
```

### Notes

- Source cloned to `$CORE_DATA/gentleman-guardian-angel/` (`~/.local/share/core-data/gentleman-guardian-angel/`)
- Binary installed to `$PREFIX/bin/gga`
- Libraries installed to `$PREFIX/share/gga/lib/`
- Clones upstream repo, applies Termux patches, then runs `install.sh` / `uninstall.sh`
- Repository is updated via `git pull` + reapply patches on `core update gga`
- Requires the gga repo to be present at runtime only during install/update (can be safely removed afterward)

## How to use it?

```bash
core install gga      # install
core update gga       # update
core uninstall gga    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show gga:es`.
