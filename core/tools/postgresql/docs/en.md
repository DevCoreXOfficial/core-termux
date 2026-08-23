## Package Information

- **Name:** PostgreSQL
- **Tags:** db, sql, server
- **Project:** https://www.postgresql.org
- **Dependencies:** None required by Core

## What is it?

Advanced open-source relational database

**Package:** postgresql  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://www.postgresql.org  
**Type:** Database (pkg)  
**License:** PostgreSQL License

### Description

PostgreSQL is a powerful, open-source object-relational database system with over 30 years of active development. It has a strong reputation for reliability, feature robustness, and performance. Core includes a dedicated manager (`core pg`) for starting, stopping, and managing PostgreSQL instances.

### Dependencies

- Installed via pkg
- Data directory managed by `core pg`

### Install

```bash
core install db --postgresql
```

### Uninstall

```bash
core uninstall db --postgresql
```

### Update

```bash
core update db --postgresql
```

### Notes

- Managed via `core pg` commands (start, stop, restart, status, init, create, drop, list, shell)
- Logs: `~/.cache/core-termux/postgresql.log`
- Automatic data directory detection
- Support for existing installations

## How to use it?

```bash
core install postgresql      # install
core update postgresql       # update
core uninstall postgresql    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show postgresql:es`.
