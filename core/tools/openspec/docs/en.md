## Package Information

- **Name:** OpenSpec
- **Tags:** ai, spec-driven, development
- **Source:** https://github.com/Fission-AI/OpenSpec
- **Dependencies:** nodejs

## What is it?

Spec-driven development (SDD) for AI coding assistants.

## How to use it?

### Quick Start

**Requires Node.js 20.19.0 or higher.**

Install OpenSpec globally:

```bash
npm install -g @fission-ai/openspec@latest
```

Then navigate to your project directory and initialize:

```bash
cd your-project
openspec init
```

> **Want your AI to do it?** Paste the [setup prompt](docs/installation.md#install-with-your-ai-assistant) into your coding assistant — it installs the CLI, runs `openspec init`, and verifies the result.

Now talk to your AI:

- **Not sure what to build yet?** Start with `/opsx:explore`, a no-stakes thinking partner that reads your code, weighs options, and shapes a plan before anything is written. ([Explore guide](docs/explore.md))
- **Already know what you want?** Go straight to `/opsx:propose <what-you-want-to-build>`.

Both are in the default profile. If you want the expanded workflow (`/opsx:new`, `/opsx:continue`, `/opsx:ff`, `/opsx:verify`, `/opsx:bulk-archive`, `/opsx:onboard`), select it with `openspec config profile` and apply with `openspec update`.

`/opsx:propose` is the canonical name; your tool may spell it `/opsx-propose` (Cursor, GitHub Copilot), `@opsx-propose` (Amazon Q) or `$openspec-propose` (Codex). `openspec init` prints the right form for the tools you picked — see [How To Invoke](docs/supported-tools.md#how-to-invoke).

> [!NOTE]
> Not sure if your tool is supported? [View the full list](docs/supported-tools.md) – we support 30+ tools and growing.
>
> Also works with pnpm, yarn, bun, and nix. [See installation options](docs/installation.md).

## Docs

**Start here:** the **[Documentation Home](docs/README.md)** maps everything. New to OpenSpec? Read [Getting Started](docs/getting-started.md), then [How Commands Work](docs/how-commands-work.md) (where you actually type `/opsx:propose`).

→ **[Getting Started](docs/getting-started.md)**: first steps<br>
→ **[Explore First](docs/explore.md)**: think it through with `/opsx:explore` before you commit<br>
→ **[How Commands Work](docs/how-commands-work.md)**: where slash commands run vs the CLI<br>
→ **[Core Concepts at a Glance](docs/overview.md)**: the whole mental model, one page<br>
→ **[Examples & Recipes](docs/examples.md)**: real changes, start to finish<br>
→ **[Workflows](docs/workflows.md)**: combos and patterns<br>
→ **[Existing Projects](docs/existing-projects.md)**: adopt OpenSpec on a brownfield codebase<br>
→ **[Editing a Change](docs/editing-changes.md)**: update artifacts, go back, reconcile manual edits<br>
→ **[Commands](docs/commands.md)**: slash commands & skills<br>
→ **[CLI](docs/cli.md)**: terminal reference<br>
→ **[Stores](docs/stores-beta/user-guide.md)**: plan in a separate repo, shared across your team (beta)<br>
→ **[Supported Tools](docs/supported-tools.md)**: tool integrations & install paths<br>
→ **[Concepts](docs/concepts.md)**: how it all fits<br>
→ **[Multi-Language](docs/multi-language.md)**: multi-language support<br>
→ **[Customization](docs/customization.md)**: make it yours<br>
→ **[FAQ](docs/faq.md)** · **[Troubleshooting](docs/troubleshooting.md)** · **[Glossary](docs/glossary.md)**: quick help


## Community schemas

Third-party schema bundles distributed via standalone repositories — these provide opinionated workflows that integrate OpenSpec with other tools, similar to how [github/spec-kit's community extension catalog](https://github.com/github/spec-kit/tree/main/extensions) handles tool integrations.

→ **[Browse the catalog](docs/customization.md#community-schemas)** in the customization docs.


## Why OpenSpec?

AI coding assistants are powerful but unpredictable when requirements live only in chat history. OpenSpec adds a lightweight spec layer so you agree on what to build before any code is written.

- **Agree before you build** — human and AI align on specs before code gets written

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `openspec`

### Common commands

```bash
cd your-project
openspec init
cd your-project
openspec init
cd your-project
openspec init
cd your-project
openspec init
```

