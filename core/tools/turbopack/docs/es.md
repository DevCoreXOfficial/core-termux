> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Turbopack (glibc)
- **Tags:** bundler, nextjs, termux
- **Proyecto:** https://nextjs.org
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Run Next.js with Turbopack on Termux (Android aarch64).

## Binario y referencia CLI

**Binario:** `next-turbopack`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
No package.json found in current or parent directories
```


### Common commands

```bash
cd my-next-app
next-turbopack dev     # Start dev server with Turbopack
next-turbopack build   # Production build with Turbopack
```

## ¿Cómo usarlo?

```bash
core install turbopack        # instalar
core update turbopack         # actualizar
core uninstall turbopack      # eliminar
```

```bash
core install turbopack      # install
core update turbopack       # update
core uninstall turbopack    # remove
```

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show turbopack`.
