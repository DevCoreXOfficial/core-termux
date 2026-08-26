> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Redis
- **Tags:** db, cache, nosql
- **Proyecto:** https://redis.io
- **Código fuente:** https://github.com/redis/redis
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Almacén de estructuras en memoria: cache, base de datos y message broker.

## Binario y referencia CLI

**Binario:** `redis-server`

Salida real de `--help` y comandos comunes:


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

## ¿Cómo usarlo?

```bash
core install redis        # instalar
core update redis         # actualizar
core uninstall redis      # eliminar
```

Example from the official README:

```bash
docker run -d -p 6379:6379 redis:latest
```

Full documentation: https://redis.io

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show redis`.
