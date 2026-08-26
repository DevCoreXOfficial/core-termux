## Package Information

- **Name:** jq
- **Tags:** json, parser
- **Project:** https://jqlang.github.io/jq/
- **Source:** https://github.com/jqlang/jq
- **Dependencies:** None required by Core

## What is it?

Command-line JSON processor

## How to use it?

Example from the official README:

```bash
docker run --rm -i ghcr.io/jqlang/jq:latest < package.json '.version'
```

Full documentation: https://jqlang.github.io/jq/

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show jq:es`.
