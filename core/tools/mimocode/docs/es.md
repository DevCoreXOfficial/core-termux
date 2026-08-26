> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** MiMoCode
- **Tags:** ai, agent, coding
- **Código fuente:** https://github.com/XiaomiMiMo/MiMo-Code
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Agente de programación de Xiaomi: rápido, local y open source.

## Binario y referencia CLI

**Binario:** `mimo`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
powershell -ep Bypass -c "irm https://mimo.xiaomi.com/install.ps1 | iex"
mimo
sudo apt install xsel
mimo serve --port 4096
ssh -N -L 4096:127.0.0.1:4096 user@remote-host
mimo attach http://127.0.0.1:4096
powershell -ep Bypass -c "irm https://mimo.xiaomi.com/install.ps1 | iex"
mimo
```

## ¿Cómo usarlo?

```bash
core install mimocode        # instalar
core update mimocode         # actualizar
core uninstall mimocode      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quick Start

```bash
# One-line install (macOS / Linux)
curl -fsSL https://mimo.xiaomi.com/install | bash

# One-line install (Windows PowerShell)
powershell -ep Bypass -c "irm https://mimo.xiaomi.com/install.ps1 | iex"

# Or install via npm (all platforms)
npm install -g @mimo-ai/cli

# Run
mimo
```

The first launch guides you through configuration automatically. Supported options:
- **Xiaomi MiMo Platform** — OAuth login
- **Codex (ChatGPT Pro/Plus)** — OpenAI OAuth login
- **Import from Claude Code** — migrate existing authentication in one step
- **Provider list** — connect catalog providers by API key, or OAuth where supported (e.g. xAI/Grok)
- **Custom Provider** — add any OpenAI-compatible API in the TUI

<details>
<summary><strong>WSL: clipboard issues</strong></summary>

If you encounter garbled text when copying on WSL, install `xsel`:
```bash
sudo apt install xsel
```
</details>

<details>
<summary><strong>macOS: rendering issues in the default terminal</strong></summary>

MiMoCode does not support the built-in macOS Terminal (Terminal.app). If the interface is misaligned, flickers, or has other rendering issues, use [iTerm2](https://iterm2.com/) or the VS Code integrated terminal instead:

```bash
brew install --cask iterm2
```
</details>

<details>
<summary><strong>TUI lag and visual animation issues</strong></summary>

If the TUI lags when run directly over SSH, render it locally and run only the MiMoCode server on the remote host. Start the server from the remote project directory:

```bash
# Remote host
mimo serve --port 4096

# Local host: create the SSH port forward
ssh -N -L 4096:127.0.0.1:4096 user@remote-host

# Local host: connect from another terminal
mimo attach http://127.0.0.1:4096
```

If decorative animation is causing the lag, run `/vivid`, or configure **Vivid visuals** in the `ctrl+p` command palette, to switch between Vivid and Minimal visuals as needed.

</details>

<details>
<summary><strong>Windows: garbled CJK (Chinese/Japanese/Korean) output in the shell</strong></summary>

On Windows with a non-UTF-8 system locale (e.g. zh-CN, whose active code page is 936/GBK),
command output containing CJK characters may appear garbled (mojibake). MiMoCode forces

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show mimocode`.
