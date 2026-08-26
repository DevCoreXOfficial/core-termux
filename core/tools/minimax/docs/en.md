## Package Information

- **Name:** MiniMax CLI
- **Tags:** ai, multimodal
- **Source:** https://github.com/MiniMax-AI/MiniMax-MCP
- **Dependencies:** None required by Core

## What is it?

Official MiniMax Model Context Protocol (MCP) server that enables interaction with powerful Text to Speech, image generation and video generation APIs.

## How to use it?

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

## Transport
We support two transport types: stdio and sse.
| stdio  | SSE  |
|:-----|:-----|
| Run locally | Can be deployed locally or in the cloud |
| Communication through `stdout` | Communication through `network` |
| Input: Supports processing `local files` or valid `URL` resources | Input: When deployed in the cloud, it is recommended to use `URL` for input |

## Available Tools
| tool  | description  |
|-|-|
|`text_to_audio`|Convert text to audio with a given voice|
|`list_voices`|List all voices available|
|`voice_clone`|Clone a voice using provided audio files|
|`generate_video`|Generate a video from a prompt|
|`text_to_image`|Generate a image from a prompt|
|`query_video_generation`|Query the result of video generation task|
|`voice_design`|Generate a voice from a prompt using preview text|

## Release Notes

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `mmx`

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
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show minimax:es`.
