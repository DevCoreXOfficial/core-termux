# Contributing to Core

Thanks for helping build Core! This guide covers the essentials. The most common contribution is **adding a new tool** — that's the focus here.

---

## The golden rule of tools

> A tool must ship an installer **for both Termux and Ubuntu/WSL**, each using the method that is correct for that platform.
>
> Only mark a tool as single-platform when it genuinely cannot run elsewhere (e.g. `extra-keys` is a Termux keyboard feature, `turbopack` exists solely as an Android glibc workaround).

- **Termux** installers use whatever Android requires: `pkg`, glibc bootstrappers, proot modes, interactive method menus.
- **Ubuntu/WSL** installers use the project's official installation channel only: apt, NodeSource, pipx, upstream `curl | bash` scripts, GitHub releases... Never reuse Termux workarounds there.
- Success/failure is judged by the **binary being present**, never by the installer's exit code (upstream scripts often exit non-zero over cosmetic errors).

---

## Adding a new tool

Create one flat directory under `core/tools/<tool>/`:

```
core/tools/mytool/
├── manifest.json        # identity, platforms, tags, dependencies
├── check.sh             # (optional) custom status check
├── docs/
│   ├── en.md            # required — English documentation
│   └── es.md            # optional — Spanish translation
├── termux/
│   ├── install.sh       # required
│   └── ...              # any Termux-only assets (helpers, wrappers)
└── ubuntu/
    ├── install.sh       # required (unless termux-only)
    └── ...
```

No central registry to edit — the engine discovers tools by scanning `tools/*/manifest.json`.

### 1. manifest.json

```json
{
  "name": "mytool",
  "display": "My Tool",
  "description": "One-line summary used by search",
  "platforms": ["termux", "ubuntu", "wsl"],
  "check_cmd": ["mytool", "mytool-cli"],
  "homepage": "https://example.com",
  "tags": ["ai", "agent", "coding"],
  "dependencies": [
    { "name": "git", "check": "git",
      "pkg": { "termux": "git", "ubuntu": "git" } },
    { "name": "nodejs", "check": "node",
      "pkg": { "termux": "nodejs-lts", "ubuntu": "nodejs npm" } }
  ]
}
```

Field notes:

| Field | Rules |
|-------|-------|
| `name` | Must equal the directory name; it's what users type |
| `display` | Human name shown in tables (e.g. `KiloCode CLI`) |
| `platforms` | `["termux", "ubuntu", "wsl"]` normally. Use fewer only for genuine single-platform tools |
| `check_cmd` | String or array — installed means ANY matches on PATH. Arrays fix distro naming (`bat`/`batcat`) |
| `tags` | Lowercase keywords powering `core search`. Be generous |
| `dependencies` | `pkg` maps package names per package manager. The dependency named `nodejs` is special: it routes through Core's canonical NodeSource/nodejs-lts installers |

### 2. Platform installers

Each installer is executed as an isolated process with a verb argument:

```bash
bash termux/install.sh install     # also: uninstall | update | reinstall | version-local | version-remote
```

**Verb contract:**

| Verb | Required | Notes |
|------|----------|-------|
| `install` | yes | Idempotent-ish; return `2` if already installed, `0` success, `1` failure |
| `uninstall` | recommended | Remove binaries AND ask about config dirs (mirror your Termux `confirm_remove_configs` paths on Ubuntu) |
| `update` | recommended | Own the **local↔remote comparison and prompt**: call `_check_update_needed "<Display>" "<local ver>" "<remote ver>" <your update fn>` exactly once, then update. Never rely on the engine to compare — `engine_update` just runs your `update` verb |
| `reinstall` | nice-to-have | uninstall then install |
| `version-local` / `version-remote` | nice-to-have | Convenience interface for manual/scripted queries (`bash install.sh version-local`). The `update` verb reuses the same version functions through `_check_update_needed` |

**UX rules:**

- **Termux**: own the whole experience — spinners (`loading`), menus (`read_select`), messages. The engine runs your script bare.
- **Ubuntu/WSL**: stay quiet for `install`/`uninstall` (the engine wraps you in a `loading` animation). But if your `update` verb compares versions via `_check_update_needed`, the engine detects the prompt and runs it directly so the question stays on the terminal.
- Write all code and user-facing strings in **English**.

**Imports cheat-sheet** (missing these causes runtime `command not found`):

```bash
import "@/utils/log"                # log_* , read_confirm_default, loading...
import "@/utils/uninstall"          # confirm_remove_configs
import "@/lib/platform"             # pm_install/pm_remove/CORE_SUDO (+ call core_detect_platform)
source "$CORE_PATH/tools/nodejs/ubuntu/install.sh" install   # node deps → canonical installer
```

Shebangs: cross-platform files use `#!/usr/bin/env bash`; generated Termux wrappers use `#!/data/data/com.termux/files/usr/bin/bash`.

### 3. Custom status — `check.sh`

For config bundles where a binary isn't enough (e.g. `nvchad` needs nvim **and** its config), add an executable `check.sh` at the tool root. Exit `0` = installed. It overrides `check_cmd`.

### 4. Documentation — `docs/en.md`

Mandatory structure:

```markdown
## Package Information
- **Name:** ...
- **Tags:** ai, agent
- **Project:** https://...
- **Dependencies:** ...

## What is it?
...

## How to use it?

## Notes
...
```

Spanish lives in `docs/es.md`; when absent, Core falls back to English automatically (`core show mytool:es`).

### 5. Test before opening a PR

```bash
bash scripts/smoke-test.sh
```

Then on a real device/shell: `core i mytool`, `core un mytool` (config prompt should appear), `core up mytool`, and confirm `core s <tag>` finds it.

---

## Single-platform tools

Set `"platforms"` accordingly and ship only the needed folder. Examples already in tree: `extra-keys` (Termux feature), `turbopack` (Android glibc shim), `proot`, `udocker`. They are hidden from `core search` on unsupported platforms and refuse to install gracefully.

## Style tools (environment tweaks)

If your contribution configures the environment rather than installing software (fonts, banners, cursor), set `"style": true` in the manifest. Those are surfaced through `core style` instead of the tool catalog, with applied/removed status.

## Code style

- Bash, 2-space indent, English everywhere (code + strings)
- Reuse helpers before inventing new ones (`loading`, `read_confirm_default`, `pm_install`)
- Run `shellcheck` if available; `bash -n` is mandatory

## Pull requests

1. Branch from `main`
2. Keep commits small and descriptive
3. `bash scripts/smoke-test.sh` must pass
4. Describe testing performed (which platform, which verbs)
