> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** OpenClaw
- **Tags:** ai, assistant
- **Código fuente:** https://github.com/openclaw/openclaw
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Asistente personal de IA para tu terminal.

## Binario y referencia CLI

**Binario:** `openclaw`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
openclaw onboard --install-daemon
openclaw gateway status
openclaw dashboard
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm build
pnpm ui:build
```

## ¿Cómo usarlo?

```bash
core install openclaw        # instalar
core update openclaw         # actualizar
core uninstall openclaw      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quick start

On a fresh install, the installer scripts start onboarding automatically.
Complete the wizard they open. If you installed the package directly with npm,
pnpm, or Bun, run:

```bash
openclaw onboard --install-daemon
```

After onboarding:

```bash
openclaw gateway status
openclaw dashboard
```

Onboarding verifies model access, creates the workspace, and configures the Gateway. The last command opens the Control UI; send a message there to confirm the assistant is working. See the [getting started guide](https://docs.openclaw.ai/start/getting-started) for channel setup and troubleshooting.


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show openclaw`.
