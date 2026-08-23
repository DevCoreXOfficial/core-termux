## Package Information

- **Name:** Ollama
- **Tags:** ai, llm, local
- **Project:** https://ollama.com
- **Dependencies:** None required by Core

## What is it?

Run open-source LLMs locally on Termux

**Package:** ollama  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://ollama.com  
**Type:** Local LLM runtime (pkg)  
**License:** MIT

### Description

Ollama allows you to run open-source LLMs locally on Termux. It supports a wide range of models including Llama, Mistral, Gemma, Qwen, DeepSeek, and many more. All processing is done locally with no data sent to external servers.

### Dependencies

- Installed via pkg (termux package)

### Install

```bash
core install ai --ollama
```

### Uninstall

```bash
core uninstall ai --ollama
```

### Update

```bash
core update ai --ollama
```

### Notes

- Runs entirely locally on your device
- Supports models from Ollama library
- Command: `ollama`
- Model storage: `~/.ollama/`

## How to use it?

```bash
core install ollama      # install
core update ollama       # update
core uninstall ollama    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show ollama:es`.
