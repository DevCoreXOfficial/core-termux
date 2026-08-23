## Package Information

- **Name:** Hugging Face CLI
- **Tags:** ai, models, datasets, ml
- **Project:** https://huggingface.co/docs/huggingface_hub
- **Dependencies:** None required by Core

## What is it?

The official Hugging Face Hub CLI — download, upload, and manage models, datasets, Spaces, buckets, repos, papers, collections, Jobs, Inference Endpoints, sandboxes, webhooks, and skills from your terminal.

**Package:** `hf` (PyPI)  
**Author:** Hugging Face  
**Official:** https://huggingface.co/docs/hub/  
**Type:** Hugging Face Hub CLI (Python venv)  
**License:** Apache 2.0

### What it is

`hf` is the official command-line interface for the Hugging Face Hub. It replaces the deprecated `huggingface-cli` command and provides a single tool for everything Hub-related: downloading and uploading models/datasets, managing Spaces and buckets, running Jobs, deploying Inference Endpoints, opening sandboxes, handling discussions and webhooks, browsing papers and collections, managing the local cache, and more.

### Install via core

```bash
core install hugging-face
```

Under the hood this runs the official installer:

```bash
curl -LsSf https://hf.co/cli/install.sh | bash
```

The installer is idempotent and always installs/upgrades to the **latest** version. It builds a Python venv at `~/.hf-cli`, symlinks the `hf` binary into `~/.local/bin/hf`, and automatically installs the `hf-cli` AI-agent skill (for Claude and other agent frameworks).

> **Note:** during a manual install you can pass `exclude-skill` to skip installing the AI-agent skill.

### Authentication

Most Hub operations require a token from https://huggingface.co/settings/tokens.

```bash
hf auth login    # browser-based login, or paste a token
hf auth whoami   # check which account you are logged in as
hf auth list     # list all stored access tokens
hf auth switch   # switch between access tokens
```

The `HF_TOKEN` environment variable is the recommended way to authenticate for scripting (over `token`):

```bash
export HF_TOKEN=hf_...
```

### Main commands

| Command | Description |
|---------|-------------|
| `hf auth ...` | Manage authentication (login, logout, whoami, switch, token) |
| `hf download REPO_ID` | Download files from the Hub |
| `hf upload REPO_ID` | Upload a file or a folder to the Hub |
| `hf cp SRC` | Copy files between local paths, repositories, and buckets |
| `hf sync` | Sync files between a local directory and a bucket |
| `hf models ...` | Interact with models on the Hub |
| `hf datasets ...` | Interact with datasets on the Hub |
| `hf spaces ...` | Interact with Spaces on the Hub |
| `hf buckets ...` | Interact with buckets |
| `hf jobs ...` | Run and manage Jobs on the Hub |
| `hf endpoints ...` | Manage Hugging Face Inference Endpoints |
| `hf repos ...` | Manage repos on the Hub |
| `hf discussions ...` | Manage discussions and pull requests on the Hub |
| `hf collections ...` | Interact with collections on the Hub |
| `hf papers ...` | Interact with papers on the Hub |
| `hf cache ...` | Manage the local cache directory |
| `hf sandbox ...` | Run and manage sandboxes on Hugging Face Jobs |
| `hf webhooks ...` | Manage webhooks on the Hub |
| `hf skills ...` | Manage skills for AI assistants |
| `hf env` | Print information about the environment |
| `hf update` | Update the `hf` CLI to the latest version |
| `hf version` | Print information about the `hf` version |

Use `hf <command> --help` for full options, descriptions, and examples.

### Usage examples

```bash
## Authenticate
hf auth login

## Download a model
hf download deepseek-ai/DeepSeek-R1

## Download a dataset
hf download HuggingFaceH4/ultrachat_200k --type dataset

## Upload a single file to a model repo
hf upload your-username/your-model model.safetensors

## Upload a folder to a dataset repo
hf upload your-username/your-dataset ./data --type dataset

## Run a Job on HF infrastructure (detached, GPU flavor, streaming the token)
hf jobs run --detach --expose 8000 --flavor a10g-small -s HF_TOKEN vllm/vllm-openai vllm serve LiquidAI/LFM2.5-8B-A1B --max-model-len 8192

## Search models
hf models search llama

## Inspect the local cache
hf cache list

## Update the CLI itself
hf update
```

### Termux notes

- Installs into a Python venv at `~/.hf-cli` with the `hf` binary symlinked at `~/.local/bin/hf`.
- Cache and config live under `~/.cache/huggingface` and `~/.config/huggingface`.
- The AI-agent skill is installed at `~/.agents/skills/hf-cli` and `~/.claude/skills/hf-cli`.
- `curl` and `python` are the only package dependencies; they are installed automatically if missing.

### Uninstall / Update

```bash
core uninstall hugging-face
core update hugging-face
```

Uninstalling asks whether to also remove the cache/config directories. Updating re-runs the official installer, which always upgrades to the latest version.

## How to use it?

```bash
core install hugging-face      # install
core update hugging-face       # update
core uninstall hugging-face    # remove
```

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Installation methods are platform-specific; Core picks the right one automatically.
- Spanish docs (when available): `core show hugging-face:es`.
