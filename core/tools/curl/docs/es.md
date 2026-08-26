> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** curl
- **Tags:** http, transfer, api
- **Proyecto:** https://curl.se
- **Código fuente:** https://github.com/curl/curl
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Transferencia de datos por URL: HTTP y más de 25 protocolos.

## Binario y referencia CLI

**Binario:** `curl`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Usage: curl [options...] <url>
 -d, --data <data>            HTTP POST data
 -f, --fail                   Fail fast with no output on HTTP errors
 -I, --head                   Show document info only
 -H, --header <header/@file>  Pass custom header(s) to server
 -h, --help <subject>         Get help for commands
 -o, --output <file>          Write to file instead of stdout
 -O, --remote-name            Write output to file named as remote file
 -i, --show-headers           Show response headers in output
 -s, --silent                 Silent mode
 -T, --upload-file <file>     Transfer local FILE to destination
 -u, --user <user:password>   Server user and password
 -A, --user-agent <name>      Send User-Agent <name> to server
 -v, --verbose                Make the operation more talkative
 -V, --version                Show version number and quit

This is not the full help; this menu is split into categories.
Use "--help category" to get an overview of all categories, which are:
auth, connection, curl, deprecated, dns, file, ftp, global, http, imap, ldap,
output, pop3, post, proxy, scp, sftp, smtp, ssh, telnet, tftp, timeout, tls,
upload, verbose.
Use "--help all" to list all options
Use "--help [option]" to view documentation for a given option
```

## ¿Cómo usarlo?

```bash
core install curl        # instalar
core update curl         # actualizar
core uninstall curl      # eliminar
```



## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show curl`.
