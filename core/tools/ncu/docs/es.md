> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** npm-check-updates
- **Tags:** updates, npm, dependencies
- **Proyecto:** https://github.com/raineorshine/npm-check-updates
- **Código fuente:** https://github.com/raineorshine/npm-check-updates
- **Dependencias:** nodejs

## ¿Qué es?

Actualiza las dependencias de package.json a sus últimas versiones.

## Binario y referencia CLI

**Binario:** `ncu`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
Upgrade a project's package file:
Check global packages:
Choose which packages to update in interactive mode:
Combine with `--format group` for a truly _luxe_ experience:
- <kbd>↑</kbd><kbd>↓</kbd> Select a package
- <kbd>Space</kbd> Toggle selection
- <kbd>a</kbd> Toggle all
- <kbd>Enter</kbd> Upgrade
```

## ¿Cómo usarlo?

```bash
core install ncu        # instalar
core update ncu         # actualizar
core uninstall ncu      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Usage

Check the latest versions of all project dependencies:

```console
$ ncu
Checking package.json
[====================] 5/5 100%

 eslint             7.32.0  →    8.0.0
 prettier           ^2.7.1  →   ^3.0.0
 svelte            ^3.48.0  →  ^3.51.0
 typescript         >3.0.0  →   >4.0.0
 untildify          <4.0.0  →   ^4.0.0
 webpack               4.x  →      5.x

Run ncu -u to upgrade package.json
```

Upgrade a project's package file:

> **Make sure your package file is in version control and all changes have been committed. This _will_ overwrite your package file.**

```console
$ ncu -u
Upgrading package.json
[====================] 1/1 100%

 express           4.12.x  →   4.13.x

Run npm install to install new versions.

$ npm install      # update installed packages and package-lock.json
```

Check global packages:

```sh
ncu -g
```


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show ncu`.
