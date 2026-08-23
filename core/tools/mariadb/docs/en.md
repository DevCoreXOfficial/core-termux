## Package Information

- **Name:** MariaDB
- **Tags:** db, sql, mysql, server
- **Project:** https://mariadb.org
- **Dependencies:** None required by Core

## What is it?

Community-developed fork of MySQL relational database

**Package:** mariadb  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://mariadb.org  
**Type:** Database (pkg)  
**License:** GPL-2.0

### Description

MariaDB is a community-developed, commercially supported fork of the MySQL relational database management system. It offers enhanced performance, storage engines, and features compared to MySQL while maintaining full compatibility.

### Dependencies

- Installed via pkg

### Install

```bash
core install db --mariadb
```

### Uninstall

```bash
core uninstall db --mariadb
```

### Update

```bash
core update db --mariadb
```

### Notes

- Full MySQL compatible
- Command: `mysql`, `mariadb`
- Data directory: `$PREFIX/var/lib/mysql/`

## How to use it?

```bash
core install mariadb      # install
core update mariadb       # update
core uninstall mariadb    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show mariadb:es`.
