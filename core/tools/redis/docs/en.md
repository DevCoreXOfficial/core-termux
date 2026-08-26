## Package Information

- **Name:** Redis
- **Tags:** db, cache, nosql
- **Project:** https://redis.io
- **Source:** https://github.com/redis/redis
- **Dependencies:** None required by Core

## What is it?

For developers, who are building real-time data-driven applications, Redis is the preferred, fastest, and most feature-rich cache, data structure server, and document and vector query engine.

## How to use it?

Example from the official README:

```bash
docker run -d -p 6379:6379 redis:latest
```

Full documentation: https://redis.io

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `redis-server`

### `--help` output

```text
Usage: ./redis-server [/path/to/redis.conf] [options] [-]
       ./redis-server - (read config from stdin)
       ./redis-server -v or --version
       ./redis-server -h or --help
       ./redis-server --test-memory <megabytes>
       ./redis-server --check-system

Examples:
       ./redis-server (run the server with default conf)
       echo 'maxmemory 128mb' | ./redis-server -
       ./redis-server /etc/redis/6379.conf
       ./redis-server --port 7777
       ./redis-server --port 7777 --replicaof 127.0.0.1 8888
       ./redis-server /etc/myredis.conf --loglevel verbose -
       ./redis-server /etc/myredis.conf --loglevel verbose

Sentinel mode:
       ./redis-server /etc/sentinel.conf --sentinel
```


### Common commands

```bash
docker run -d -p 6379:6379 redis:latest
```

