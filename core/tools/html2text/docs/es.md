> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** html2text
- **Tags:** html, conversion
- **Código fuente:** https://github.com/Alir3z4/html2text
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Convierte HTML a texto plano legible.

## Binario y referencia CLI

**Binario:** `html2text`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Unrecognized command line option "--help", try "-help".
```


### Common commands

```bash
>>> import html2text
>>>
>>> print(html2text.html2text("<p><strong>Zed's</strong> dead baby, <em>Zed's</em> dead.</p>"))
**Zed's** dead baby, _Zed's_ dead.
```

## ¿Cómo usarlo?

```bash
core install html2text        # instalar
core update html2text         # actualizar
core uninstall html2text      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
>>> import html2text
>>>
>>> print(html2text.html2text("<p><strong>Zed's</strong> dead baby, <em>Zed's</em> dead.</p>"))
**Zed's** dead baby, _Zed's_ dead.
```

Full documentation: https://github.com/Alir3z4/html2text

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show html2text`.
