## Package Information

- **Name:** Cactus Engine CLI
- **Tags:** ai, llm, mobile, inference
- **Project:** https://cactuscompute.com
- **Dependencies:** None required by Core

## What is it?

A hybrid edge-cloud AI engine for mobiles, wearables, smart home and robots — quantization, kernels, runtime and inference with OpenAI-compatible APIs for text, speech and vision.

**Package:** cactus-compute  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core  
**Official:** https://github.com/cactus-compute/cactus  
**Type:** AI edge-cloud inference engine CLI (Python + glibc)  
**License:** Cactus Compute License (proprietary)

### What it is

Cactus Engine is the **runtime** behind the Cactus ecosystem. The `cactus` CLI drives a hybrid edge-cloud inference engine: models ship quantized for low-power devices, kernels run locally, and heavier workloads can be offloaded to the cloud while keeping an OpenAI-compatible API (text / speech / vision) on the device side. The upstream publishes a self-contained manylinux aarch64 wheel (~24 MB) that embeds the native engine at `cactus/bindings/lib/libcactus_engine.so` (4.6 MB) — no C++ build is needed.

CLI commands:

```bash
cactus run <model...>      # run a model (local or hybrid)
cactus serve               # start the OpenAI-compatible inference server
cactus transcribe          # speech-to-text
cactus build <model>       # build / export a model
cactus convert             # convert a checkpoint
cactus upload              # upload a model to the cloud
cactus list                # list available models
cactus auth                # manage cloud credentials
cactus clean               # clean caches / artifacts
cactus code                # code-assist endpoint
cactus test                # run engine tests
```

The heavy `convert` pipeline (torch/torchvision/transformers/**scipy**/**sentencepiece**) is an optional extra — this installer does **not** install it. Core deps are `numpy`, `huggingface-hub`, `fastapi`, `uvicorn` and friends only.

### What it is NOT (read this first)

Cactus Engine is the **engine**, not a specific model. It is distinct from Cactus Needle:

- **Cactus Needle** (`cactus-needle` package) is a ~14 MB function-calling *model* — a single checkpoint with a small CLI.
- **Cactus Engine** (`cactus-compute` package) is the *runtime* that can run Needle and other models, serve OpenAI-compatible APIs, and do quantization/inference.

They are separate PyPI packages and separate tools. This tool (`core/tools/ai/cactus`) installs the **engine CLI** (`cactus`); the separate `cactus-needle` tool installs the **model CLI** (`needle`). Installing the engine does not replace or install the needle model.

### Termux adaptation (what this installer does)

Cactus Engine is Python-based and ships only glibc (manylinux) wheels. Termux's native Android (bionic) Python rejects manylinux wheels, so a plain native Termux install is impossible. This installer adapts the **runtime environment**, not the tool: it installs the official wheels into a glibc-resident Python instead of trying to compile anything.

```bash
core install cactus
```

You will be prompted to choose:

1. **glibc (recommended)** — pip installs `cactus-compute` into the termux-glibc Python 3.12 (`python-glibc`), launched via `glibc-runner`. The wheel embeds the native engine, so no C++ build is required.
2. **glibc + proot (fix)** — the same glibc Python, executed under proot to bypass "bad system call" errors on some Android kernels.
3. **Proot-distro (alternative)** — pip install inside an Ubuntu 24.04 proot-distro container (plain `/usr` glibc, closest to upstream expectations).

### Known issues on Termux (glibc method)

- **First-run model download may fail with** `RuntimeError: ... Reqwest error: builder error` — the `hf-xet` backend (Rust) misbehaves under the Termux glibc environment. Workaround: disable it for the session:

  ```bash
  HF_HUB_DISABLE_XET=1 cactus run ...
  ```

  huggingface_hub then falls back to classic HTTP. Export it (`export HF_HUB_DISABLE_XET=1`) if HF downloads keep failing. The `cactus` wrappers install by this tool already export it.
- Native Termux (bionic) is not offered: the wheel is manylinux (glibc) only.
- Installing downloads the ~24 MB wheel plus core Python deps into the glibc Python environment.
- The `cactus` CLI has **no `version` flag** — updates compare the installed PyPI version against PyPI via `importlib.metadata`.
- The package is licensed under the **Cactus Compute License** (proprietary, not open source).

### Usage

```bash
## List models available to the engine
cactus list

## Run a local model
cactus run <model>

## Start the OpenAI-compatible server (text/speech/vision)
cactus serve

## Transcribe audio
cactus transcribe <audio-file>
```

### Uninstall / Update

```bash
core uninstall cactus
core update cactus
```

### Notes

- The install method is recorded in `~/.local/share/core-data/cactus-cli/.install-method`
- First-run model downloads land in the standard HF cache under `~/.cache/huggingface/`
- Data directory: `~/.local/share/core-data/cactus-cli/`

### Installation method (v5)

Native on-device build from the official `cactus-compute/cactus` v2.0.1 source: cmake + ARM NEON kernels produce `libcactus_engine.so`, then `run`/`transcribe` binaries are built and cleaned with `termux-elf-cleaner` (fixes Bionic TLS alignment). **No glibc and no proot involved.** Includes upstream-compat patches: `requires-python` relaxed for Python 3.14 and bundle validation accepting SentencePiece tokenizers (`tokenizer.model`). Optional `convert` stack (transformers 5.5.4) installed best-effort.

## How to use it?

```bash
core install cactus      # install
core update cactus       # update
core uninstall cactus    # remove
```

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `cactus`

### `--help` output

```text
  Cactus CLI:

  -----------------------------------------------------------------

  cactus auth                          manage cloud API key
    --status                           show key status
    --clear                            remove saved key

  cactus run [model|path]              run a model (default: google/gemma-4-E2B-it)
    --bits 1|2|3|4                     CQ quantization (default: 4)
    --image <path>                     image file for VLM inference
    --audio <path>                     audio file for audio chat
    --system <prompt>                  system prompt
    --prompt <text>                    send prompt immediately
    --thinking                         enable thinking/reasoning mode
    --token <token>                    HuggingFace token (gated models)
    --reconvert                        force local convert fallback

  cactus transcribe [model]            live microphone transcription with a model
    --file <audio.wav>                 audio file to transcribe (WAV)
    --language <code>                  language code (default: en)
    --bits 1|2|3|4                     CQ quantization (default: 4)
    --token <token>                    HuggingFace token (gated models)
    --reconvert                        force local rebuild from source

  cactus download [model]              fetch a prebuilt bundle, else build locally (default: google/gemma-4-E2B-it)
    --bits 1|2|3|4                     CQ quantization (default: 4)
    --token <token>                    HuggingFace token (gated models)
    --reconvert                        force local rebuild from source

  cactus convert <model> [dir]         build a runnable bundle locally (skips prebuilt fetch)
    --bits 1|2|3|4                     CQ quantization (default: 4)
    --token <token>                    HuggingFace token (gated models)
    --reconvert                        force local rebuild from source
    --lora <path>                      merge a LoRA adapter before converting

  cactus serve [model]                 OpenAI-compatible local HTTP server
    --host <addr>                      bind address (default: 127.0.0.1)
    --port <port>                      port (default: 8080)
    --bits 1|2|3|4                     CQ quantization (default: 4)
    --token <token>                    HuggingFace token (gated models)
    --reconvert                        force local rebuild from source
    --no-cloud-handoff                 disable automatic cloud handoff
    --confidence-threshold <0..1>      handoff to cloud below this confidence
    --cloud-timeout-ms <n>             max wait for cloud handoff before local fallback

  cactus list                          list downloaded models

  cactus build                         build cactus libraries
    --apple                            Apple (iOS/macOS)
    --android                          Android
    --python                           shared lib for Python FFI

  cactus test                          run the test suite
    --component <name>                 kernels | graph | engine | all
```


### Common commands

```bash
cactus run <model...>      # run a model (local or hybrid)
cactus serve               # start the OpenAI-compatible inference server
cactus transcribe          # speech-to-text
cactus build <model>       # build / export a model
cactus convert             # convert a checkpoint
cactus upload              # upload a model to the cloud
cactus list                # list available models
cactus auth                # manage cloud credentials
```

