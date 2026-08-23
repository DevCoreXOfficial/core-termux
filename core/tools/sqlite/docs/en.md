## Package Information

- **Name:** SQLite
- **Tags:** db, sql, embedded
- **Project:** https://www.sqlite.org
- **Dependencies:** None required by Core

## What is it?

Self-contained, serverless, zero-configuration SQL database engine

**Package:** sqlite  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://www.sqlite.org  
**Type:** Database (pkg)  
**License:** Public Domain

### Description

SQLite is a C-language library that implements a small, fast, self-contained, high-reliability, full-featured SQL database engine. It is the most used database engine in the world, embedded in virtually every mobile phone and most computers.

### Dependencies

- Installed via pkg

### Install

```bash
core install db --sqlite
```

### Uninstall

```bash
core uninstall db --sqlite
```

### Update

```bash
core update db --sqlite
```

### Notes

- Zero configuration required
- No server process needed
- Database is a single file on disk
- Command: `sqlite3`

## How to use it?

```bash
core install sqlite      # install
core update sqlite       # update
core uninstall sqlite    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show sqlite:es`.
