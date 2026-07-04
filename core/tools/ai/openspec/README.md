# OpenSpec

Spec-Driven Development framework for AI coding assistants

**Package:** @fission-ai/openspec (npm global package)  
**Author:** Fission AI  
**Repository:** https://github.com/Fission-AI/openspec  
**Type:** Spec-Driven Development (SDD) framework / AI workflow orchestrator  
**License:** MIT

## Description

OpenSpec is an open-source, CLI-driven framework that implements **Spec-Driven Development (SDD)** for AI coding assistants. Instead of asking an AI to "just build a feature," OpenSpec forces the creation of structured, source-of-truth specifications that AI agents can reference to produce more accurate, maintainable code.

It bridges the gap between human intent and AI output by formalizing technical requirements into structured Markdown documents — **Proposals, Specs, Design notes, and Tasks** — stored in an `/openspec/` folder within your project repository.

Key features:
- **Structured Artifacts** — Proposals, Specs, Design docs, and Tasks stored in `/openspec/`
- **AI Context Management** — AI agents reference specs to understand architecture and requirements
- **Reduced Hallucinations** — Shifts AI from guess-based coding to verification-based coding
- **CLI-first workflow** — Generate and iterate on specs entirely from the terminal
- **Framework agnostic** — Works with Claude Code, Cursor, GitHub Copilot, and any AI coding tool

## Dependencies

- Node.js LTS (nodejs-lts)

## Install

```bash
core install ai --openspec
```

## Uninstall

```bash
core uninstall ai --openspec
```

## Update

```bash
core update ai --openspec
```

## Usage

Once installed, initialize OpenSpec in your project:

```bash
openspec init
```

To propose a new capability:

```bash
openspec propose "your idea"
```

To view existing specs:

```bash
openspec list
```

## Typical Workflow

1. **Proposal** — Create a high-level proposal describing the desired capability
2. **Spec & Design** — Define exact functionality in `/openspec/specs/`
3. **Task Definition** — Break complex features into small actionable tasks
4. **Implementation** — AI executes against the defined specs
5. **Archive** — Finished docs are archived as living documentation

## Notes

- Installed as a global npm package: `@fission-ai/openspec`
- Command: `openspec`
- Requires Node.js LTS (installed automatically if missing)
- Creates an `/openspec/` directory in your project for all documentation
- Ideal companion for any AI coding agent that needs structured context
