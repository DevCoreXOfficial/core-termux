## Package Information

- **Name:** Gentleman Guardian Angel
- **Tags:** ai, code-review
- **Source:** https://github.com/Gentleman-Programming/gentleman-guardian-angel
- **Dependencies:** None required by Core

## What is it?

😇 Gentleman Guardian Angel (gga) - Provider-agnostic code review using AI. Use Claude, Gemini, Codex, Ollama to enforce your coding standards.

## How to use it?

### Example

<img width="962" height="941" alt="image" src="https://github.com/user-attachments/assets/c8963dff-6aa5-420c-b58b-1416e81af384" />

## 🎯 Why?

You have coding standards. Your team ignores them. Code reviews catch issues too late.

**GGA** runs on every commit, validating staged files against your `AGENTS.md`. Like having a senior developer review every line before it hits the repo.

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│   git commit    │ ──▶ │  AI Review   │ ──▶ │  ✅ Pass/Fail   │
│  (staged files) │     │  (any LLM)   │     │  (with details) │
└─────────────────┘     └──────────────┘     └─────────────────┘
```

- 🔌 **Provider agnostic** — Claude, Gemini, Codex, OpenCode, Cursor Agent, Kilo, Kiro, Ollama, LM Studio, GitHub Models, MiniMax
- 📦 **Pure Bash core** — no runtime framework; individual providers may require their own CLI or API tooling
- 🪝 **Git native** — Standard pre-commit hook
- ⚡ **Smart caching** — Skip unchanged files
- 🔍 **PR review mode** — Review full PRs, not just last commit
- 🪟 **Cross-platform** — macOS, Linux, Windows (Git Bash), WSL

---

## 📦 Installation

### Homebrew (recommended)

```bash
brew install gentleman-programming/tap/gga
```

### Manual

```bash
git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git
cd gentleman-guardian-angel
./install.sh
```

### Windows (Git Bash, PowerShell, cmd.exe)

```bash
git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git
cd gentleman-guardian-angel
bash install.sh
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

On Windows, the installer also creates `~/bin/gga.bat` so `gga` can be called from `cmd.exe` and PowerShell. Add `%USERPROFILE%\bin` to your Windows user `PATH` for those shells; `.bashrc` only affects Git Bash.

> **WSL** is also fully supported — no special configuration needed.

### Oh My Zsh users

If you use [Oh My Zsh](https://ohmyz.sh/) with the `git` plugin enabled (the default), the alias `gga` will conflict with this CLI. You'll see:

```
git: 'gui' is not a git command. See 'git --help'.
```

**Fix:** Add this line to your `~/.zshrc` after the Oh My Zsh source line:

```bash
unalias gga 2>/dev/null

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `gga`

### Common commands

```bash
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│   git commit    │ ──▶ │  AI Review   │ ──▶ │  ✅ Pass/Fail   │
│  (staged files) │     │  (any LLM)   │     │  (with details) │
└─────────────────┘     └──────────────┘     └─────────────────┘
git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git
cd gentleman-guardian-angel
./install.sh
git clone https://github.com/Gentleman-Programming/gentleman-guardian-angel.git
```

