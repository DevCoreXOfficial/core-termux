# PostgreSQL

Advanced open-source relational database

**Package:** postgresql  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://www.postgresql.org  
**Type:** Database (pkg)  
**License:** PostgreSQL License

## Description

PostgreSQL is a powerful, open-source object-relational database system with over 30 years of active development. It has a strong reputation for reliability, feature robustness, and performance. Core-Termux includes a dedicated manager (`core pg`) for starting, stopping, and managing PostgreSQL instances.

## Dependencies

- Installed via pkg
- Data directory managed by `core pg`

## Install

```bash
core install db --postgresql
```

## Uninstall

```bash
core uninstall db --postgresql
```

## Update

```bash
core update db --postgresql
```

## Notes

- Managed via `core pg` commands (start, stop, restart, status, init, create, drop, list, shell)
- Logs: `~/.cache/core-termux/postgresql.log`
- Automatic data directory detection
- Support for existing installations

