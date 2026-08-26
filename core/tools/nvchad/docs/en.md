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

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `nvim`

### `--help` output

```text
Usage:
  nvim [options] [file ...]

Options:
  --cmd <cmd>           Execute <cmd> before any config
  +<cmd>, -c <cmd>      Execute <cmd> after config and first file
  -l <script> [args...] Execute Lua <script> (with optional args)
  -S <session>          Source <session> after loading the first file
  -s <scriptin>         Read Normal mode commands from <scriptin>
  -u <config>           Use this config file

  -d                    Diff mode
  -es, -Es              Silent (batch) mode
  -h, --help            Print this help message
  -i <shada>            Use this shada file
  -n                    No swap file, use memory only
  -o[N]                 Open N windows (default: one per file)
  -O[N]                 Open N vertical windows (default: one per file)
  -p[N]                 Open N tab pages (default: one per file)
  -R                    Read-only (view) mode
  -v, --version         Print version information
  -V[N][file]           Verbose [level][file]

  --                    Only file names after this
  --api-info            Write msgpack-encoded API metadata to stdout
  --clean               "Factory defaults" (skip user config and plugins, shada)
  --embed               Use stdin/stdout as a msgpack-rpc channel
  --headless            Don't start a user interface
  --listen <address>    Serve RPC API from this address
  --remote[-subcommand] Execute commands remotely on a server
  --server <address>    Connect to this Nvim server
  --startuptime <file>  Write startup timing messages to <file>

See ":help startup-options" for all options.
```

