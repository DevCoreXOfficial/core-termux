## Package Information

- **Name:** SuperCode CLI
- **Tags:** ai, agent, coding
- **Dependencies:** None required by Core

## What is it?

The open source SWE agent — AI-powered coding assistant with multi-model support

**Package:** supercode-cli (npm global package)  
**Author:** Yash Devwasthale — [@yashdev9274](https://github.com/yashdev9274)  
**Repository:** https://github.com/yashdev9274/supercli  
**Website:** https://supercodeai.vercel.app/  
**Documentation:** https://supercli-docs.vercel.app  
**Runtime:** Bun  
**License:** MIT

### Description

SuperCode is an open-source SWE (Software Engineering) agent that brings AI-powered code generation, debugging, and project management to your terminal. It supports multiple model providers including Claude, GPT, Gemini, DeepSeek, Groq, Mistral, and more — giving you the freedom to choose the best model for each task.

Key features:

- **Multi-provider AI** — Bring your own model: Claude, GPT, Gemini, DeepSeek, Ollama, OpenRouter, Groq, Mistral, and many more
- **File operations** — Read, write, edit, and search files in your project
- **Command execution** — Run shell commands and scripts from within the agent
- **Project scaffolding** — `supercode init` to scaffold new projects
- **GitHub integration** — Login with GitHub for seamless repository management
- **Skills system** — Add, remove, and list agent skills for specialized tasks
- **Free models included** — No API key required to get started
- **Terminal-first** — Designed for the command line, with a browser mirror available at terminal.supercli.com

### Dependencies

- Bun (installed automatically if missing)

### Install

```bash
core install supercode
```

### Uninstall

```bash
core uninstall supercode
```

### Update

```bash
core update supercode
```

### Usage

Once installed, authenticate with GitHub:

```bash
supercode login
```

Scaffold a new project:

```bash
supercode init
```

Run SuperCode as your coding agent:

```bash
supercode
```

### Available Commands

| Command | Description |
|---------|-------------|
| `supercode` | Start the interactive coding agent session |
| `supercode login` | Authenticate with GitHub |
| `supercode init` | Scaffold a new project |
| `supercode skills add <skill>` | Add a new agent skill |
| `supercode skills remove <skill>` | Remove an agent skill |
| `supercode skills list` | List installed skills |

### Supported Providers

Claude (Anthropic), GPT (OpenAI), Gemini (Google), DeepSeek, Groq, Mistral, Ollama, OpenRouter, GitHub Models, LM Studio, NEAR AI, Xiaomi MiMo, LiteLLM, and more via the provider system.

### Notes

- Installed as a global npm package: `supercode-cli`
- Command: `supercode`
- Built with Bun + TypeScript + Turborepo
- Requires Bun runtime (installed automatically if missing)
- Open source under MIT license
- Active development — check the changelog at https://supercodeai.vercel.app/changelog

## How to use it?

```bash
core install supercode      # install
core update supercode       # update
core uninstall supercode    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show supercode:es`.
