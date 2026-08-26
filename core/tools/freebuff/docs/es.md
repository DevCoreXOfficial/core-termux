> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Freebuff
- **Tags:** ai, agent, coding
- **Código fuente:** https://github.com/CodebuffAI/codebuff-community
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Agente de programación 100%% gratis desde tu terminal.

## Binario y referencia CLI

**Binario:** `freebuff`

Salida real de `--help` y comandos comunes:


### `--help` output

```text
Usage: freebuff [options] [command]

Freebuff - Free AI coding assistant

Arguments:
  command                       Command to run (choices: "login")

Options:
  -v, --version                 Print the CLI version
  --continue [conversation-id]  Continue from a previous conversation
                                (optionally specify a conversation id)
  --cwd <directory>             Set the working directory (default: current
                                directory)
  -h, --help                    Show this help message
```


### Common commands

```bash
OR
You can also start codebuff in an existing project directory:
```

## ¿Cómo usarlo?

```bash
core install freebuff        # instalar
core update freebuff         # actualizar
core uninstall freebuff      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
Example from the official README:

```bash
OR

You can also start codebuff in an existing project directory:
```

Full documentation: https://github.com/CodebuffAI/codebuff-community

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show freebuff`.
