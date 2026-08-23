## Package Information

- **Name:** Redis
- **Tags:** db, cache, nosql
- **Project:** https://redis.io
- **Dependencies:** None required by Core

## What is it?

In-memory data structure store used as database, cache, and message broker

**Package:** redis  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://redis.io  
**Type:** Database (pkg)  
**License:** BSD-3-Clause

### Description

Redis is an open-source (BSD-licensed), in-memory data structure store, used as a database, cache, and message broker. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes, and streams.

### Dependencies

- Installed via pkg

### Install

```bash
core install db --redis
```

### Uninstall

```bash
core uninstall db --redis
```

### Update

```bash
core update db --redis
```

### Notes

- No special configuration required for basic usage
- Server binary: `redis-server` — client binary: `redis-cli`
- Default port: 6379
- Start the server with: `redis-server --daemonize yes`
- Connect with: `redis-cli`
- Test connectivity: `redis-cli PING` (should reply `PONG`)
- Data persists to disk even when server is stopped

## How to use it?

```bash
core install redis      # install
core update redis       # update
core uninstall redis    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show redis:es`.
