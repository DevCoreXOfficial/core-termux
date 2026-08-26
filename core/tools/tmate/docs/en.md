## Package Information

- **Name:** tmate
- **Tags:** remote, sharing, pairing
- **Project:** https://tmate.io
- **Dependencies:** None required by Core

## What is it?

Instant terminal sharing for pair programming

**Package:** tmate  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://tmate.io  
**Type:** Development tool (pkg)  
**License:** Apache 2.0 / BSD 2-Clause

### Description

Tmate is a fork of tmux that allows you to share your terminal session instantly with anyone. It creates a secure SSH connection that others can join to view or control your terminal, perfect for pair programming and remote debugging.

### Dependencies

- Installed via pkg

### Install

```bash
core install tmate
```

### Uninstall

```bash
core uninstall tmate
```

### Update

```bash
core update tmate
```

### Notes

- Command: `tmate`
- Creates instant SSH session
- Supports read-only and read-write sharing
- No registration required

## How to use it?

```bash
core install tmate      # install
core update tmate       # update
core uninstall tmate    # remove
```

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `tmate`

### `--help` output

```text
Usage: tmate [options] [tmux-command [flags]]

Basic options:
 -n <name>    specify the session token instead of getting a random one
 -r <name>    same, but for the read-only token
 -k <key>     specify an api-key, necessary for using named sessions on tmate.io
 -F           set the foreground mode, useful for setting remote access
 -f <path>    set the config file path
 -S <path>    set the socket path, useful to issue commands to a running tmate instance
 -v           set verbosity (can be repeated)
 -V           print version
```

