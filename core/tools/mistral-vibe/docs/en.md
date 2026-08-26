## Package Information

- **Name:** Mistral Vibe
- **Tags:** ai, agent, coding
- **Source:** https://github.com/mistralai/mistral-vibe
- **Dependencies:** None required by Core

## What is it?

Minimal CLI coding agent by Mistral

## How to use it?

### Quick Start

1. Navigate to your project's root directory:

   ```bash
   cd /path/to/your/project
   ```

2. Run Vibe:

   ```bash
   vibe
   ```

3. If this is your first time running Vibe, it will:
   - Use built-in defaults without creating a configuration file until you
     save a setting
   - Prompt you to enter your API key if it's not already configured
   - Save your API key to `~/.vibe/.env` for future use

   Alternatively, you can configure your API key separately using `vibe --setup`.

4. Start interacting with the agent!

   ```
   > Can you find all instances of the word "TODO" in the project?

   🤖 The user wants to find all instances of "TODO". The `grep` tool is perfect for this. I will use it to search the current directory.

   > grep(pattern="TODO", path=".")

   ... (grep tool output) ...

   🤖 I found the following "TODO" comments in your project.
   ```

### Usage

### Interactive Mode

Simply run `vibe` to enter the interactive chat loop.

- **Multi-line Input**: Press `Ctrl+J` or `Shift+Enter` for select terminals to insert a newline.
- **File Paths**: Reference files in your prompt using the `@` symbol for smart autocompletion (e.g., `> Read the file @src/agent.py`).
- **Shell Commands**: Prefix any command with `!` to execute it directly in your shell, bypassing the agent (e.g., `> !ls -l`).
- **External Editor**: Press `Ctrl+G` to edit your current input in an external editor.
- **Tool Output Toggle**: Press `Ctrl+O` to toggle the tool output view.
- **Todo View Toggle**: Press `Ctrl+T` to toggle the todo list view.
- **Debug Console**: Press `Ctrl+\` to toggle the debug console.
- **Agent Selection**: Press `Shift+Tab` to cycle through agents (ask, plan, ...).
- **Exit**: Type `/exit`, `exit`, `quit`, `:q`, or `:quit` in the input box, or press `Ctrl+C` / `Ctrl+D` twice within ~1 second. Set `ask_confirmation_on_exit = false` (or toggle it in `/config`) to make `Ctrl+D` quit on the first press; `Ctrl+C` always requires confirmation.

### Copying & Text Selection

- **Copy**: Use `Ctrl+Y` or `Ctrl+Shift+C` to copy the current selection to clipboard. With autocopy enabled (default via `autocopy_to_clipboard = true`), mouse selection automatically copies on release and shows a brief confirmation.
- **Multi-click selection**: Double-click selects a word, triple-click selects the paragraph. Dragging extends the selection at the same granularity.

You can start Vibe with a prompt using the following command:

```bash
vibe "Refactor the main function in cli/main.py to be more modular."
```

### Trust Folder System

Vibe includes a trust folder system to ensure you only run the agent in directories you trust. When you first run Vibe in a new directory which contains a `.vibe` subfolder, it may ask you to confirm whether you trust the folder.

Trusted folders are remembered for future sessions. You can manage trusted folders through its configuration file `~/.vibe/trusted_folders.toml`.

This safety feature helps prevent accidental execution in sensitive directories.

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `vibe`

### Common commands

```bash
cd /path/to/your/project
vibe
> Can you find all instances of the word "TODO" in the project?
> grep(pattern="TODO", path=".")
... (grep tool output) ...
🤖 I found the following "TODO" comments in your project.
vibe "Refactor the main function in cli/main.py to be more modular."
cd /path/to/your/project
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show mistral-vibe:es`.
