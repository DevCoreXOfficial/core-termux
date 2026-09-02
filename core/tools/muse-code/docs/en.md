## Package Information

- **Name:** Muse Code
- **Author:** Meta
- **Project:** https://developer.meta.com/ai/products/muse-code/
- **Repository:** https://github.com/meta/muse-code
- **Dependencies:** proot, curl, python

## What is it?

Meta Muse Code is an interactive terminal AI coding agent that runs under `proot` on Termux to work around Android's app-data isolation, while on Ubuntu/WSL it uses the official installer. It provides conversational code assistance, file editing, and task automation directly in your terminal.

## How to use it?

Launch the agent from any project directory:

```bash
muse-code
# alias
muse
```

On first run it authenticates and downloads the model binary via its launcher.

Common workflow:

```bash
muse-code --help
muse-code --version
muse-code
```

## Notes

- **Termux:** Downloads and verifies the Meta launcher from `https://api.meta.ai/muse-launcher.sh` with checksum verification, uses `proot` with bindings for `/data`, `/storage`, etc., installs linker config and timezone data.
- **Ubuntu/WSL:** Uses the official installer `https://dev.meta.ai/install.sh`.
- Binaries: `muse-code` (primary) and `muse` alias.
- Data directory: `~/.local/share/muse-code`.
