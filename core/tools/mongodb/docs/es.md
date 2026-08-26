> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** MongoDB
- **Tags:** db, nosql, documents
- **Proyecto:** https://www.mongodb.com
- **Código fuente:** https://github.com/mongodb/mongo
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Base de datos NoSQL orientada a documentos.

## Binario y referencia CLI

**Binario:** `mongosh`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Options:
  --networkMessageCompressors arg (=snappy,zstd,zlib)
                                        Comma-separated list of compressors to
                                        use for network messages

General options:
  -h [ --help ]                         Show this usage information
  --version                             Show version information
  -f [ --config ] arg                   Configuration file specifying
                                        additional options
  --configExpand arg                    Process expansion directives in config
                                        file (none, exec, rest)
  --port arg                            Specify port number - 27017 by default
  --ipv6                                Enable IPv6 support (disabled by
                                        default)
  --listenBacklog arg (=128)            Set socket listen backlog size
  --maxConns arg (=1000000)             Max number of simultaneous connections
  --pidfilepath arg                     Full path to pidfile (if not set, no
                                        pidfile is created)
  --timeZoneInfo arg                    Full path to time zone info directory,
                                        e.g. /usr/share/zoneinfo
  --nounixsocket                        Disable listening on unix sockets
  --unixSocketPrefix arg                Alternative directory for UNIX domain
                                        sockets (defaults to /tmp)
  --filePermissions arg                 Permissions to set on UNIX domain
                                        socket file - 0700 by default
  --fork                                Fork server process
  -v [ --verbose ] [=arg(=v)]           Be more verbose (include multiple times
                                        for more verbosity e.g. -vvvvv)
  --quiet                               Quieter output
  --logpath arg                         Log file to send write to instead of
                                        stdout - has to be a file, not
                                        directory
  --syslog                              Log to system's syslog facility instead
                                        of file or stdout
  --syslogFacility arg                  syslog facility used for mongodb syslog
                                        message
  --logappend                           Append to logpath instead of
                                        over-writing
  --logRotate arg                       Set the log rotation behavior
                                        (rename|reopen)
  --timeStampFormat arg                 Desired format for timestamps in log
                                        messages. One of iso8601-utc or
                                        iso8601-local
  --setParameter arg                    Set a configurable parameter
  --bind_ip arg                         Comma separated list of ip addresses to
                                        listen on - localhost by default
  --bind_ip_all                         Bind to all ip addresses
  --noauth                              Run without security
  --transitionToAuth                    For rolling access control upgrade.
                                        Attempt to authenticate over outgoing
                                        connections and proceed regardless of
                                        success. Accept incoming connections
                                        with or without authentication.
  --slowms arg (=100)                   Value of slow for profile and console
```


### Common commands

```bash
$ ./mongod --help
Full documentation: https://www.mongodb.com
<!-- cli-reference -->
- **Binary:** `mongosh` (aliases: `mongod`, `mongo`)
```

## ¿Cómo usarlo?

```bash
core install mongodb        # instalar
core update mongodb         # actualizar
core uninstall mongodb      # eliminar
```

Example from the official README:

```bash
$ ./mongod --help
```

To run a single server database:
```

Full documentation: https://www.mongodb.com

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show mongodb`.
