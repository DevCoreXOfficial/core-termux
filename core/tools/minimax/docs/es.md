> 🇪🇸 **Documentación en español.** Los comandos, banderas y salidas de ayuda
> se mantienen en su idioma original porque así se usan en la terminal.

## Información del Paquete

- **Nombre:** MiniMax CLI
- **Tags:** ai, multimodal
- **Código fuente:** https://github.com/MiniMax-AI/MiniMax-MCP
- **Dependencias:** ninguna requerida por Core

## ¿Qué es?

Genera texto, imágenes, video y voz desde tu terminal.

## Binario y referencia CLI

**Binario:** `mmx`

Salida real de `--help` y comandos comunes:


### Common commands

```bash
{
"mcpServers": {
"MiniMax": {
"command": "uvx",
"args": [
"minimax-mcp",
"-y"
],
```

## ¿Cómo usarlo?

```bash
core install minimax        # instalar
core update minimax         # actualizar
core uninstall minimax      # eliminar
```

> Extracto de la documentación oficial (en inglés):
>
### Quickstart with MCP Client

1. Get your API key from [MiniMax](https://www.minimax.io/platform/user-center/basic-information/interface-key). 
2. Install `uv` (Python package manager), install with `curl -LsSf https://astral.sh/uv/install.sh | sh` or see the `uv` [repo](https://github.com/astral-sh/uv) for additional install methods.
3. **Important**: The API host and key vary by region and must match; otherwise, you'll encounter an `Invalid API key` error.

|Region| Global  | Mainland  |
|:--|:-----|:-----|
|MINIMAX_API_KEY| go get from [MiniMax Global](https://www.minimax.io/platform/user-center/basic-information/interface-key) | go get from [MiniMax](https://platform.minimaxi.com/user-center/basic-information/interface-key) |
|MINIMAX_API_HOST| https://api.minimax.io | https://api.minimaxi.com |


### Claude Desktop
Go to `Claude > Settings > Developer > Edit Config > claude_desktop_config.json` to include the following:

```
{
  "mcpServers": {
    "MiniMax": {
      "command": "uvx",
      "args": [
        "minimax-mcp",
        "-y"
      ],
      "env": {
        "MINIMAX_API_KEY": "insert-your-api-key-here",
        "MINIMAX_MCP_BASE_PATH": "local-output-dir-path, such as /User/xxx/Desktop",
        "MINIMAX_API_HOST": "api host, https://api.minimax.io | https://api.minimaxi.com",
        "MINIMAX_API_RESOURCE_MODE": "optional, [url|local], url is default, audio/image/video are downloaded locally or provided in URL format"
      }
    }
  }
}

```
⚠️ Warning: The API key needs to match the host. If an error "API Error: invalid api key" occurs, please check your api host:
- Global Host：`https://api.minimax.io`
- Mainland Host：`https://api.minimaxi.com`

If you're using Windows, you will have to enable "Developer Mode" in Claude Desktop to use the MCP server. Click "Help" in the hamburger menu in the top left and select "Enable Developer Mode".


### Cursor
Go to `Cursor -> Preferences -> Cursor Settings -> MCP -> Add new global MCP Server` to add above config.

That's it. Your MCP client can now interact with MiniMax through these tools:


## Notas

- Plataformas soportadas: **termux, ubuntu, wsl**.
- En Termux algunas herramientas ofrecen varios métodos de instalación (menú interactivo); en Ubuntu/WSL se usan siempre métodos oficiales.
- Documentación completa en inglés: `core show minimax`.
