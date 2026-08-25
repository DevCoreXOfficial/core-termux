## Package Information

- **Name:** Neovim
- **Tags:** editor, nvim, nvchad, lsp
- **Project:** https://neovim.io
- **Dependencies:** None required by Core

## What is it?

Fast, extensible code editor (modern Vim fork)

**Package:** neovim  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://neovim.io  
**Type:** Code editor (pkg)  
**License:** Apache 2.0

### Description

Neovim is a hyper-extensible, modern fork of Vim. It provides a powerful editing experience with built-in LSP support, asynchronous job control, and a plugin architecture that allows extensive customization. It serves as the foundation for the NvChad configuration.

### Dependencies

- Installed via pkg

### Install

```bash
core install nvchad
```

### Uninstall

```bash
core uninstall neovim
```

### Update

```bash
core update neovim
```

### Notes

- Command: `nvim`
- Can be configured standalone or with NvChad
- Supports LSP, treesitter, and Lua configuration

## How to use it?

```bash
core install nvchad      # install
core update neovim       # update
core uninstall neovim    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show neovim:es`.
# NvChad

Modern Neovim configuration with preconfigured plugins

**Package:** nvchad (configuration)  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/vendored inside Core (tools/nvchad/<platform>/nvim)  
**Type:** Code editor configuration (git clone)  
**License:** MIT

## Description

NvChad is a modern Neovim configuration that provides a complete IDE-like experience out of the box. The Core-Termux version includes GitHub Copilot, CodeCompanion AI, preconfigured LSP support, syntax highlighting, file explorer, and much more.

## Dependencies

- Neovim, git, nodejs-lts, python, perl, curl, wget
- lua-language-server, ripgrep, stylua, tree-sitter

## Install

```bash
core install nvchad
```

## Uninstall

```bash
core uninstall nvchad
```

## Update

```bash
core update nvchad
```

## Notes

- Installs to `~/.config/nvim/`
- Includes GitHub Copilot and CodeCompanion
- Preconfigured for TypeScript, JavaScript, Python, PHP, Perl, Rust, Lua
- For detailed information: https://github.com/vendored inside Core (tools/nvchad/<platform>/nvim)


> NvChad is bundled: `core install nvchad` sets up both.
