## Package Information

- **Name:** Codex CLI
- **Tags:** ai, agent, coding
- **Source:** https://github.com/openai/codex
- **Dependencies:** nodejs

## What is it?

Lightweight coding agent that runs in your terminal

## How to use it?

### Quickstart

### Installing and running Codex CLI

Run the following on Mac or Linux to install Codex CLI:

```shell
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

Run the following on Windows to install Codex CLI:

```shell
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

The standalone installers download from `https://releases.openai.com/codex` by default and fall back to GitHub Releases if a metadata or asset download is unavailable. To force GitHub Releases, set `CODEX_INSTALLER_USE_RELEASES_OPENAI_COM` to `false` (`0` and `no` are also accepted):

```shell
curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_INSTALLER_USE_RELEASES_OPENAI_COM=false sh
```

```powershell
$env:CODEX_INSTALLER_USE_RELEASES_OPENAI_COM='false'; irm https://chatgpt.com/codex/install.ps1 | iex
```

Codex CLI can also be installed via the following package managers:

```shell

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `codex`

### Common commands

```bash
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
Codex CLI can also be installed via the following package managers:
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
Codex CLI can also be installed via the following package managers:
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
Codex CLI can also be installed via the following package managers:
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
Codex CLI can also be installed via the following package managers:
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show codex:es`.
