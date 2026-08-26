## Package Information

- **Name:** Hugging Face CLI
- **Tags:** ai, models, datasets, ml
- **Project:** https://huggingface.co/docs/huggingface_hub
- **Source:** https://github.com/huggingface/huggingface_hub
- **Dependencies:** python, pip

## What is it?

The official CLI and Python client for the Hugging Face Hub.

## How to use it?

### Quick start

Install the [`hf` CLI](https://huggingface.co/docs/huggingface_hub/en/guides/cli) with the standalone installer:

```bash
# On macOS and Linux.
curl -LsSf https://hf.co/cli/install.sh | bash
```

```powershell
# On Windows.
powershell -ExecutionPolicy ByPass -c "irm https://hf.co/cli/install.ps1 | iex"
```

Log in, then start working with the Hub:

```bash
# Log in (use --token $HF_TOKEN in non-interactive environments)
hf auth login

# Find models served by Inference Providers
hf models ls --warm

# Download a model
hf download Qwen/Qwen3-0.6B

# Upload files to your own repo
hf upload username/my-cool-model ./model.safetensors

# Sync a local folder to a storage bucket
hf buckets sync ./checkpoints hf://buckets/username/my-bucket

# Run a job on Hugging Face infrastructure
hf jobs run python:3.12 python -c "print('Hello from the cloud!')"

# Discover everything else
hf --help
```

The Hub uses tokens to authenticate applications (see [docs](https://huggingface.co/docs/hub/security-tokens)). Check out the [CLI guide](https://huggingface.co/docs/huggingface_hub/en/guides/cli) for a tour of the main features.

## What is `huggingface_hub`?

The `huggingface_hub` library allows you to interact with the [Hugging Face Hub](https://huggingface.co/), a platform democratizing open-source Machine Learning for creators and collaborators. Discover pre-trained models and datasets for your projects, play with the thousands of machine learning apps hosted on the Hub, or create and share your own models, datasets and demos with the community. Everything ships in one package with two interfaces: the [`hf` CLI](https://huggingface.co/docs/huggingface_hub/en/guides/cli) for your terminal and the `huggingface_hub` library for Python — both designed to work well for humans and AI agents. Use them to:

- [Download files](https://huggingface.co/docs/huggingface_hub/en/guides/download) from the Hub.
- [Upload files](https://huggingface.co/docs/huggingface_hub/en/guides/upload) to the Hub.
- [Manage your repositories](https://huggingface.co/docs/huggingface_hub/en/guides/repository).
- [Run Inference](https://huggingface.co/docs/huggingface_hub/en/guides/inference) on deployed models.
- [Run Jobs](https://huggingface.co/docs/huggingface_hub/en/guides/jobs) on Hugging Face infrastructure.
- [Search](https://huggingface.co/docs/huggingface_hub/en/guides/search) for models, datasets and Spaces.
- [Share Model Cards](https://huggingface.co/docs/huggingface_hub/en/guides/model-cards) to document your models.
- [Engage with the community](https://huggingface.co/docs/huggingface_hub/en/guides/community) through PRs and comments.
- Do all of the above from the terminal with the [`hf` CLI](https://huggingface.co/docs/huggingface_hub/en/guides/cli).

## Built for humans and AI agents

The `hf` CLI is designed for people and coding agents alike: the same commands adapt their output when run by an agent. If you use Claude Code, Codex, Cursor, or another coding agent, install the `hf` CLI Skill — a command reference generated from your installed CLI:

```bash
# for Codex, Cursor, OpenCode, Pi and other agents that load skills from `.agents/skills`
hf skills add
# includes the above + Claude Code
hf skills add --claude
```

Learn more in the [Hugging Face CLI for AI agents guide](https://huggingface.co/docs/hub/agents-cli) and the [announcement blog post](https://huggingface.co/blog/hf-cli-for-agents).

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `hf`

### `--help` output

```text
Usage: hf [OPTIONS] [COMMAND] [ARGS]...

  Hugging Face Hub CLI

Options:
  --install-completion  Install completion for the current shell.
  --show-completion     Show completion for the current shell, to copy it or
                        customize the installation.
  -h, --help            Show this message and exit.

Main commands:
  auth                 Manage authentication (login, logout, etc.).
  buckets              Commands to interact with buckets.
  cache                Manage local cache directory.
  collections          Interact with collections on the Hub.
  cp                   Copy files between local paths, repositories, and
                       buckets.
  datasets             Interact with datasets on the Hub.
  discussions          Manage discussions and pull requests on the Hub.
  download             Download files from the Hub.
  endpoints            Manage Hugging Face Inference Endpoints.
  extensions           Manage hf CLI extensions. [alias: ext]
  jobs                 Run and manage Jobs on the Hub.
  models               Interact with models on the Hub.
  papers               Interact with papers on the Hub.
  repos                Manage repos on the Hub. [alias: repo]
  sandbox              Run and manage sandboxes on Hugging Face Jobs.
  skills               Manage skills for AI assistants.
  spaces               Interact with spaces on the Hub.
  sync                 Sync files between local directory and a bucket.
  upload               Upload a file or a folder to the Hub.
  upload-large-folder  [Deprecated] Upload a large folder to the Hub.
  webhooks             Manage webhooks on the Hub.

Help commands:
  env      Print information about the environment.
  update   Update the `hf` CLI to the latest version.
  version  Print information about the hf version.

Examples
  $ hf cp hf://username/my-model/config.json
  $ hf download meta-llama/Llama-3.2-1B-Instruct
  $ hf upload my-cool-model . .
  $ hf upload-large-folder Wauplin/my-cool-model ./large_model_dir

Learn more
  Use `hf <command> --help` for more information about a command.
  Read the documentation at
  https://huggingface.co/docs/huggingface_hub/en/guides/cli
```


### Common commands

```bash
Log in, then start working with the Hub:
- [Download files](https://huggingface.co/docs/huggingface_hub/en/guides/download) from the Hub.
- [Upload files](https://huggingface.co/docs/huggingface_hub/en/guides/upload) to the Hub.
- [Manage your repositories](https://huggingface.co/docs/huggingface_hub/en/guides/repository).
- [Run Inference](https://huggingface.co/docs/huggingface_hub/en/guides/inference) on deployed models.
- [Run Jobs](https://huggingface.co/docs/huggingface_hub/en/guides/jobs) on Hugging Face infrastructure.
- [Search](https://huggingface.co/docs/huggingface_hub/en/guides/search) for models, datasets and Spaces.
- [Share Model Cards](https://huggingface.co/docs/huggingface_hub/en/guides/model-cards) to document your models.
```

