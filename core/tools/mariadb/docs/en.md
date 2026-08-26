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

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `mariadb` (aliases: `mysql`)

### `--help` output

```text
mariadb from 12.3.2-MariaDB, client 15.2 for Android (aarch64) using  EditLine wrapper
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Usage: mariadb [OPTIONS] [database]

Default options are read from the following files in the given order:
/data/data/com.termux/files/usr/etc/my.cnf ~/.my.cnf
The following groups are read: mysql mariadb-client client client-server client-mariadb
The following options may be given as the first argument:
--print-defaults          Print the program argument list and exit.
--no-defaults             Don't read default options from any option file.
The following specify which files/extra groups are read (specified before remaining options):
--defaults-file=#         Only read default options from the given file #.
--defaults-extra-file=#   Read this file after the global files are read.
--defaults-group-suffix=# Additionally read default groups with # appended as a suffix.

  -?, --help          Display this help and exit.
  -I, --help          Synonym for -?
  --abort-source-on-error
                      Abort 'source filename' operations in case of errors
  --auto-rehash       Enable automatic rehashing. One doesn't need to use
                      'rehash' to get table and field completion, but startup
                      and reconnecting may take a longer time.
                      (Defaults to on; use --skip-auto-rehash to disable.)
  -A, --no-auto-rehash
                      No automatic rehashing. One has to use 'rehash' to get
                      table and field completion. This gives a quicker start of
                      mysql and disables rehashing on reconnect.
  --auto-vertical-output
                      Automatically switch to vertical output mode if the
                      result is wider than the terminal width.
  -B, --batch         Don't use history file. Disable interactive behavior.
                      (Enables --silent.)
  --binary-as-hex     Print binary data as hex
  --binary-mode       Binary mode allows certain character sequences to be
                      processed as data that would otherwise be treated with a
                      special meaning by the parser. Specifically, this switch
                      turns off parsing of all client commands except \C and
                      DELIMITER in non-interactive mode (i.e., when binary mode
                      is combined with either 1) piped input, 2) the --batch
                      mysql option, or 3) the 'source' command). Also, in
                      binary mode, occurrences of '\r\n' and ASCII '\0' are
                      preserved within strings, whereas by default, '\r\n' is
                      translated to '\n' and '\0' is disallowed in user input.
  --character-sets-dir=name
                      Directory for character set files.
  --column-names      Write column names in results.
                      (Defaults to on; use --skip-column-names to disable.)
  -N, --skip-column-names
                      Don't write column names in results.
  --column-type-info  Display column type information.
  -c, --comments      Preserve comments. Send comments to the server. The
                      default is --skip-comments (discard comments), enable
                      with --comments.
  -C, --compress      Use compression in server/client protocol.
```

