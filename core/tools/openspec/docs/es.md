> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** OpenSpec
- **Tags:** ai, spec-driven, development
- **Código fuente:** https://github.com/Fission-AI/OpenSpec
- **Dependencias:** nodejs

## ¿Qué es?

Framework de desarrollo guiado por especificaciones (Spec-Driven Development).

## Binario y referencia CLI

**Binario:** `openspec`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
cd your-project
openspec init
cd your-project
openspec init
cd your-project
openspec init
cd your-project
openspec init
```

## ¿Cómo usarlo?

```bash
core install openspec        # instalar
core update openspec         # actualizar
core uninstall openspec      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quick Start

**Requires Node.js 20.19.0 or higher.**

Install OpenSpec globally:

```bash
npm install -g @fission-ai/openspec@latest
```

Then navigate to your project directory and initialize:

```bash
cd your-project
openspec init
```

> **Want your AI to do it?** Paste the [setup prompt](docs/installation.md#install-with-your-ai-assistant) into your coding assistant — it installs the CLI, runs `openspec init`, and verifies the result.

Now talk to your AI:

- **Not sure what to build yet?** Start with `/opsx:explore`, a no-stakes thinking partner that reads your code, weighs options, and shapes a plan before anything is written. ([Explore guide](docs/explore.md))
- **Already know what you want?** Go straight to `/opsx:propose <what-you-want-to-build>`.

Both are in the default profile. If you want the expanded workflow (`/opsx:new`, `/opsx:continue`, `/opsx:ff`, `/opsx:verify`, `/opsx:bulk-archive`, `/opsx:onboard`), select it with `openspec config profile` and apply with `openspec update`.

`/opsx:propose` is the canonical name; your tool may spell it `/opsx-propose` (Cursor, GitHub Copilot), `@opsx-propose` (Amazon Q) or `$openspec-propose` (Codex). `openspec init` prints the right form for the tools you picked — see [How To Invoke](docs/supported-tools.md#how-to-invoke).

> [!NOTE]
> Not sure if your tool is supported? [View the full list](docs/supported-tools.md) – we support 30+ tools and growing.
>
> Also works with pnpm, yarn, bun, and nix. [See installation options](docs/installation.md).


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show openspec`.
