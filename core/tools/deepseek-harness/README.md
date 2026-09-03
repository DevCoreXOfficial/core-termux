# DeepSeek Harness

Open-source agent harness by DeepSeek AI with an everything-is-a-plugin architecture.

**Package:** deepseek-harness
**Author:** DeepSeek AI
**Repository:** https://github.com/deepseek-ai/deepseek-harness
**Type:** AI coding agent (npm global package)
**License:** MIT

## Description

DeepSeek Harness (`dsh`) is an open-source agent harness built on Cordis's plugin system. Every capability is a plugin: models, tools, skills, sessions, sandboxes, storage, loops, scheduling, and the UI.

## Dependencies

- Node.js LTS (nodejs-lts)
- clang (for native npm addons: koffi, node-pty)
- make (build tool)
- cmake (for koffi native addon)

## Install

```bash
core install deepseek-harness
```

## Uninstall

```bash
core uninstall deepseek-harness
```

## Update

```bash
core update deepseek-harness
```

## Notes

- npm package: `@deepseek-ai/dsh`
- Command: `dsh`
- Developer preview status
- Web UI starts at http://127.0.0.1:3080
