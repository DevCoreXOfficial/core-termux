## Package Information

- **Name:** Context7
- **Tags:** ai, docs, mcp
- **Project:** https://context7.com
- **Dependencies:** nodejs

## What is it?

Up-to-date documentation for AI coding agents

**Package:** ctx7 (npm global package)  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/upstash/context7  
**Type:** AI documentation provider (MCP server)  
**License:** MIT

### Description

Context7 solves the "stale knowledge" problem in AI coding assistants by providing them with **real-time, version-specific documentation and code examples**. When an AI agent needs to know how to use a specific library or API, Context7 fetches the latest official documentation on-demand, eliminating hallucinations and deprecated code suggestions.

It works as a **Model Context Protocol (MCP) server** that AI agents like Claude Code, Cursor, and others can query for live documentation. It can also be used directly via CLI to fetch library docs.

Key features:
- **Live documentation injection** — AI agents query Context7 for the latest API docs
- **MCP protocol support** — native integration with MCP-compatible agents
- **Skill-based fallback** — works even without MCP via CLI-based skills
- **Framework agnostic** — compatible with any AI coding environment

### Dependencies

- Node.js LTS (nodejs-lts)

### Install

```bash
core install ctx7
```

### Uninstall

```bash
core uninstall ctx7
```

### Update

```bash
core update ctx7
```

### Usage

Once installed, initialize Context7 for your AI agent:

```bash
npx ctx7 setup
```

Or specify a specific agent:

```bash
npx ctx7 setup --claude
npx ctx7 setup --cursor
```

To remove the configuration:

```bash
npx ctx7 remove
```

### Notes

- Installed as a global npm package: `ctx7`
- Command: `ctx7`
- Requires Node.js LTS (installed automatically if missing)
- Not an AI agent itself — it's a documentation provider that enhances other agents
- Ideal companion for Claude Code, Cursor, OpenCode, and other AI coding tools

## How to use it?

```bash
core install ctx7      # install
core update ctx7       # update
core uninstall ctx7    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show ctx7:es`.
