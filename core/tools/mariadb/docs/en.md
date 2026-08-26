## Package Information

- **Name:** MariaDB
- **Tags:** db, sql, mysql, server
- **Project:** https://mariadb.org
- **Source:** https://github.com/MariaDB/server
- **Dependencies:** None required by Core

## What is it?

MariaDB server is a community developed fork of MySQL server. Started by core members of the original MySQL team, MariaDB actively works with outside developers to deliver the most featureful, stable, and sanely licensed open SQL server in the industry.

## How to use it?

### Key features

* **Native vector search**. A built-in VECTOR data type with approximate
  nearest-neighbour indexing (HNSW), available since MariaDB 11.8 with
  no extension required.
* **Pluggable storage engines**. InnoDB (default for transactional workloads),
  Aria, MyRocks, ColumnStore for analytics, Spider for sharding, and S3
  for archival, among others.
* **Replication and clustering**. Asynchronous, semi-synchronous, and
  parallel replication with global transaction IDs, plus Galera synchronous
  multi-primary clustering.
* **Advanced SQL**. Common table expressions and recursive CTEs, window
  functions, system-versioned (temporal) tables, sequences, and a broad set
  of JSON functions.
* **MySQL and Oracle compatibility**. Wire-protocol and syntax compatibility
  with MySQL, plus an Oracle SQL mode supporting PL/SQL-style stored routines.
* **Spatial and full-text search**. GIS data types and functions, and built-in
  full-text indexing.
* **Security**. Role-based access control, pluggable authentication (ed25519,
  PAM, GSSAPI, and more), data-at-rest encryption, and TLS for connections.

## Documentation

* [Project home, community, and getting involved](https://mariadb.org)
* [Reference manual and release notes](https://mariadb.com/docs/)
* [MariaDB compared to MySQL](https://mariadb.com/docs/release-notes/community-server/about/compatibility-and-differences/mariadb-vs-mysql-features)

## Releases

MariaDB Server follows a yearly long-term support (LTS) model alongside
quarterly rolling releases. Binary LTS releases are maintained for three years
and are recommended for production; rolling releases deliver new features
sooner with a shorter support window.

For the current version and full history, see
 [Releases](https://github.com/MariaDB/server/releases) and
 the [MariaDB release calendar](https://mariadb.org/mariadb/all-releases/).

## Installing

Packages and installation instructions for all supported platforms are
available at [https://mariadb.org/download/](https://mariadb.org/download/).

## Building from source

To build MariaDB from source and run the test suite, follow the
[developer guide](https://mariadb.org/get-involved/getting-started-for-developers/get-code-build-test/)

It covers building the code correctly, running the MariaDB testing framework,
and choosing the right branch to target for contributions.

## Contributing

Contributions are welcome, from code and documentation to bug reports and
reviews. See [CONTRIBUTING.md](CONTRIBUTING.md) to
get started, and [CODING_STANDARDS.md](CODING_STANDARDS.md)
for code style. Contributors and community members are recognised in
[CREDITS](CREDITS).

## Getting help

* [Zulip chat](https://mariadb.zulipchat.com/)
* [Maria Discuss mailing list](https://lists.mariadb.org/postorius/lists/discuss.lists.mariadb.org/)
* [Bug reports](https://jira.mariadb.org)
* Security vulnerabilities: see [SECURITY.md](SECURITY.md)

## Licensing

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show mariadb:es`.
