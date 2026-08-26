> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** bc
- **Tags:** calculator, math

- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Arbitrary precision calculator language

## Binario y referencia CLI

**Binario:** `bc`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
usage: bc [options] [file ...]
  -h  --help         print this usage and exit
  -i  --interactive  force interactive mode
  -l  --mathlib      use the predefined math routines
  -q  --quiet        don't print initial banner
  -s  --standard     non-standard bc constructs are errors
  -w  --warn         warn about non-standard bc constructs
  -v  --version      print version information and exit

Please report bugs to <bug-bc@gnu.org>
```

## ¿Cómo usarlo?

```bash
core install bc        # instalar
core update bc         # actualizar
core uninstall bc      # eliminar
```



## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show bc`.
