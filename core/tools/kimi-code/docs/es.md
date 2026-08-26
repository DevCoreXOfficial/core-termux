> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** Kimi Code
- **Tags:** ai, agent, coding
- **Código fuente:** https://github.com/MoonshotAI/kimi-cli
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

CLI del agente de programación Kimi de Moonshot AI.

## Binario y referencia CLI

**Binario:** `kimi`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
Then you can create Kimi CLI threads in IDE's agent panel.
![](./docs/media/acp-integration.gif)
You can use Kimi CLI together with Zsh, to empower your shell experience with AI agent capabilities.
Install the [zsh-kimi-cli](https://github.com/MoonshotAI/zsh-kimi-cli) plugin via:
> [!NOTE]
Then add `kimi-cli` to your Zsh plugin list in `~/.zshrc`:
After restarting Zsh, you can switch to agent mode by pressing `Ctrl-X`.
<!-- cli-reference -->
```

## ¿Cómo usarlo?

```bash
core install kimi-code        # instalar
core update kimi-code         # actualizar
core uninstall kimi-code      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Key Features

### Shell command mode

Kimi CLI is not only a coding agent, but also a shell. You can switch the shell command mode by pressing `Ctrl-X`. In this mode, you can directly run shell commands without leaving Kimi CLI.

![](./docs/media/shell-mode.gif)

> [!NOTE]
> Built-in shell commands like `cd` are not supported yet.

### VS Code extension

Kimi CLI can be integrated with [Visual Studio Code](https://code.visualstudio.com/) via the [Kimi Code VS Code Extension](https://marketplace.visualstudio.com/items?itemName=moonshot-ai.kimi-code).

![VS Code Extension](./docs/media/vscode.png)

### IDE integration via ACP

Kimi CLI supports [Agent Client Protocol] out of the box. You can use it together with any ACP-compatible editor or IDE.

[Agent Client Protocol]: https://github.com/agentclientprotocol/agent-client-protocol

To use Kimi CLI with ACP clients, make sure to run Kimi CLI in the terminal and send `/login` to complete the login first. Then, you can configure your ACP client to start Kimi CLI as an ACP agent server with command `kimi acp`.

For example, to use Kimi CLI with [Zed](https://zed.dev/) or [JetBrains](https://blog.jetbrains.com/ai/2025/12/bring-your-own-ai-agent-to-jetbrains-ides/), add the following configuration to your `~/.config/zed/settings.json` or `~/.jetbrains/acp.json` file:

```json
{
  "agent_servers": {
    "Kimi CLI": {
      "type": "custom",
      "command": "kimi",
      "args": ["acp"],
      "env": {}
    }
  }
}
```

Then you can create Kimi CLI threads in IDE's agent panel.

![](./docs/media/acp-integration.gif)

### Zsh integration

You can use Kimi CLI together with Zsh, to empower your shell experience with AI agent capabilities.

Install the [zsh-kimi-cli](https://github.com/MoonshotAI/zsh-kimi-cli) plugin via:

```sh
git clone https://github.com/MoonshotAI/zsh-kimi-cli.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/kimi-cli
```

> [!NOTE]
> If you are using a plugin manager other than Oh My Zsh, you may need to refer to the plugin's README for installation instructions.

Then add `kimi-cli` to your Zsh plugin list in `~/.zshrc`:

```sh
plugins=(... kimi-cli)
```

After restarting Zsh, you can switch to agent mode by pressing `Ctrl-X`.

### MCP support

<!-- cli-reference -->


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show kimi-code`.
