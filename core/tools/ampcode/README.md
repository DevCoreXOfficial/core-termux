# AMP Code CLI

Amp is the frontier agent, for people who want the most out of an agent, rather than keeping their old ways.

**Package:** `@ampcode/cli`  
**Author:** DevCoreX
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://ampcode.com  
**Type:** glibc-binary

## Description

AMP Code is an AI coding agent by Sourcegraph that runs directly in your terminal, helping you understand, edit, and automate code using state-of-the-art AI models. It supports interactive conversations, one-shot commands, and seamless integration into your development workflow.

## Installation

```bash
core install ai --ampcode
```

## Usage

```bash
amp                      # Start interactive mode
amp "your prompt"        # Start with an initial prompt
amp -x "your prompt"     # Execute a single task and exit
amp login                # Sign in to your Amp account
amp update               # Update AMP Code CLI
```

## Management

```bash
core show ai --ampcode
core update ai --ampcode
core reinstall ai --ampcode
core uninstall ai --ampcode
```

> **Note:** On the first launch, you'll be prompted to authenticate with your Amp account before using the CLI.
