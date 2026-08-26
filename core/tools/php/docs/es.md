> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** PHP
- **Tags:** language, runtime
- **Proyecto:** https://www.php.net
- **Código fuente:** https://github.com/php/php-src
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Lenguaje de propósito general enfocado en desarrollo web.

## Binario y referencia CLI

**Binario:** `php`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Usage: php [options] [-f] <file> [--] [args...]
   php [options] -r <code> [--] [args...]
   php [options] [-B <begin_code>] -R <code> [-E <end_code>] [--] [args...]
   php [options] [-B <begin_code>] -F <file> [-E <end_code>] [--] [args...]
   php [options] -S <addr>:<port> [-t docroot] [router]
   php [options] -- [args...]
   php [options] -a

  -a               Run as interactive shell (requires readline extension)
  -c <path>|<file> Look for php.ini file in this directory
  -n               No configuration (ini) files will be used
  -d foo[=bar]     Define INI entry foo with value 'bar'
  -e               Generate extended information for debugger/profiler
  -f <file>        Parse and execute <file>.
  -h               This help
  -i               PHP information
  -l               Syntax check only (lint)
  -m               Show compiled in modules
  -r <code>        Run PHP <code> without using script tags <?..?>
  -B <begin_code>  Run PHP <begin_code> before processing input lines
  -R <code>        Run PHP <code> for every input line
  -F <file>        Parse and execute <file> for every input line
  -E <end_code>    Run PHP <end_code> after processing all input lines
  -H               Hide any passed arguments from external tools.
  -S <addr>:<port> Run with built-in web server.
  -t <docroot>     Specify document root <docroot> for built-in web server.
  -s               Output HTML syntax highlighted source.
  -v               Version number
  -w               Output source with stripped comments and whitespace.

  args...          Arguments passed to script. Use -- args when first argument
                   starts with - or script is read from stdin

  --ini            Show configuration file names
  --ini=diff       Show INI entries that differ from the built-in default

  --rf <name>      Show information about function <name>.
  --rc <name>      Show information about class <name>.
  --re <name>      Show information about extension <name>.
  --rz <name>      Show information about Zend extension <name>.
  --ri <name>      Show configuration for extension <name>.

  --repeat <count> Repeat script execution <count> times.
                   For internal purposes only.
```


### Common commands

```bash
./buildconf
Full documentation: https://www.php.net
<!-- cli-reference -->
- **Binary:** `php`
```

## ¿Cómo usarlo?

```bash
core install php        # instalar
core update php         # actualizar
core uninstall php      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
./buildconf
```

Configure your build. `--enable-debug` is recommended for development, see
`./configure --help` for a full list of options.
```

Full documentation: https://www.php.net

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show php`.
