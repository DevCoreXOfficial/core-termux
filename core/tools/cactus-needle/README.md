# Cactus Needle

An open 45M-parameter model for tool calling, device use and structured extraction — the whole model is a single ~14 MB engine that runs a session in about 28 MB of RAM.

**Package:** cactus-needle  
**Author:** DevCoreX  
**Repository:** https://github.com/DevCoreXOfficial/core-termux  
**Official:** https://github.com/cactus-compute/needle  
**Type:** Python tool-calling model CLI (glibc/JAX adaptation)  
**License:** See official repository (MIT)

## What it is

Needle 2 is a **function-calling model**, not a chatbot. You declare your tools (schemas), give it a query, and it answers with structured JSON function calls. It is built on the Simple Attention Network recipe, quantized to CQ2, and baked into a single engine binary that is fetched once from Hugging Face (`Cactus-Compute/needle2`) and cached — after that, inference does no network at all.

- **Simple contract**: text in, JSON out. A byte-level grammar compiled from your schemas constrains every token, so the call JSON cannot be malformed.
- **Confidence-gated**: every response carries a calibrated confidence score. Act on a call at or above your threshold; below it, re-ask or escalate to a bigger model.
- **No reasoning, no free text**: it does not chat, does not write prose, and refuses anything no declared tool can serve with the empty call `[]`.
- **Tool retrieval**: declare a large catalogue and a built-in retrieval head renders only the top five tools per turn (unselected tools are unreachable, not merely unlikely).
- **Bounded memory**: a 256-token sliding window with tools pinned as KV sinks keeps memory near ~28 MB no matter how long the conversation runs.

## What it is NOT (read this first)

Needle is the **hands**, not the **brain**. It maps "pon un timer de 5 minutos" to `{"name":"set_timer","arguments":{"minutes":5}}` — it does not reason, plan, or hold a general conversation. That is by design: the project's contract is *"act at or above the confidence threshold, escalate below it"*. So:

- **In an agent like OpenCode**: keep the reasoning model doing the thinking; OpenCode's own models already do function calling natively, so needle is not a replacement backend. Needle shines where the *whole job is calling tools*, or as a cheap offline intent→call extractor in front of your own pipeline.
- **Where it genuinely shines**: on-device / edge / embedded tool calling, voice assistants, smart-home and device control, API action layers, and structured data extraction — private, offline, sub-100 MB, instant, and per-toolset fine-tunable.

## How to use it

### CLI (version 2.0.x installed by this installer)

```bash
# Web UI to test tools interactively (http://127.0.0.1:7860)
needle playground
needle playground --weights my_needle.cact     # a tuned model

# Single inference — requires a checkpoint (see Checkpoints below)
needle run --checkpoint checkpoints/needle2.pkl --query "pon un timer de 5 minutos" \
  --tools '[{"name":"set_timer","parameters":{"type":"object","properties":{"minutes":{"type":"integer"}}}}]'

# LoRA fine-tune on your own tools (base checkpoint auto-downloads if omitted)
needle finetune data.jsonl --epochs 3 --lora-rank 16 --lr 1e-4

# Synthesize training data from a tool schema (needs OPENROUTER_API_KEY)
needle generate-data --tools my_tools.json --num-samples 500 --output data.jsonl

# Merge the adapter and export a tuned single-file .cact
needle build checkpoints/needle2.pkl --lora checkpoints/needle_lora.pkl --out my_needle.cact --bits 2
```

In **zsh**, always single-quote the `--tools` JSON: `[...]` is a glob pattern and zsh will throw `no matches found: [name:set_timer]` if it is unquoted.

### Python API

```python
import needle

@needle.tool
def get_weather(city: str):
    "Get the current weather for a city."
    return {"city": city, "temp_c": 27, "sky": "clear"}

agent = needle.Needle(tools=[get_weather])
print(agent.run("what's it like in Lagos right now?")["results"])
```

`Needle(tools=... , weights="my.cact", tool_index_path="tools.idx")` exposes `run()`, `complete()` (raw call), `extract()` (typed extraction via Pydantic), and `reset()`. `needle.Field` / `Annotated` constrain argument values at the grammar level. Turn responses look like:

```json
{ "type": "call", "function_calls": [{"name": "set_lights", "arguments": {"room": "living room", "on": true}}],
  "reasoning": "'living room' -> room; 'dim' -> on true", "confidence": 0.94 }
```

The fine-tuning data format is JSONL: `{"query": ..., "tools": [...], "answers": [{"name": ..., "arguments": ...}], "reasoning": ...}`.

## Checkpoints / weights

- `needle run` **requires** `--checkpoint <path>`. The base checkpoint auto-downloads (via `huggingface_hub`) when you run `finetune` or `build` without one, or you can point `run` at a tuned `.cact` — the engine is weights-agnostic.
- Downloads land in the standard HF cache under `~/.cache/huggingface/` (plus `~/.cache/needle`); first `playground`/`finetune` run fetches the native engine wheel once.

## Termux adaptation (what this installer does)

Cactus Needle is Python/JAX-based, and its core native dependencies — `jaxlib`, `scipy`, `sentencepiece` — publish only glibc (manylinux) wheels. Termux's native Android (bionic) Python rejects manylinux wheels, so a plain native Termux install is impossible (`No matching distribution found for jaxlib`). This installer adapts the **runtime libraries**, not the tool: it installs the official glibc wheels into a glibc-resident Python instead of trying to compile anything.

```bash
core install ai --cactus-needle
```

You will be prompted to choose:

1. **glibc (recommended)** — pip installs `cactus-needle` + wheels into the termux-glibc Python 3.12 (`python-glibc`), launched via `glibc-runner`. Validated on-device: JAX 0.11 loads and runs under the glibc prefix on aarch64.
2. **glibc + proot (fix)** — the same glibc Python, executed under proot to bypass "bad system call" errors on some Android kernels.
3. **Proot-distro (alternative)** — pip install inside an Ubuntu 24.04 proot-distro container (plain `/usr` glibc, closest to upstream expectations).

## Known issues on Termux (glibc method)

- **First-run download may fail with** `RuntimeError: ... Reqwest error: builder error` — the `hf-xet` backend (Rust) misbehaves under the Termux glibc environment. Workaround: disable it for the session:

  ```bash
  HF_HUB_DISABLE_XET=1 needle playground
  ```

  huggingface_hub then falls back to classic HTTP. Export it (`export HF_HUB_DISABLE_XET=1`) if HF downloads keep failing.
- Native Termux (bionic) is not offered: `jaxlib` has no Android/bionic wheel.
- Installing downloads large native dependencies (`jaxlib`, `scipy`) into the glibc Python environment (~500 MB).
- The `needle` CLI has **no `--version` flag** — updates compare the installed PyPI version against PyPI via `importlib.metadata`.

## Uninstall / Update

```bash
core uninstall ai --cactus-needle
core update ai --cactus-needle
```

## Notes

- The install method is recorded in `~/.local/share/core-termux-data/cactus-needle/.install-method`
- The JAX cache (`~/.cache/jax`) is shared with other JAX workloads and is not removed on uninstall
- Data directory: `~/.local/share/core-termux-data/cactus-needle/`