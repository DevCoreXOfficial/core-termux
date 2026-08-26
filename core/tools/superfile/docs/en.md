## Package Information

- **Name:** SuperFile
- **Tags:** file-manager, tui
- **Project:** https://superfile.dev
- **Source:** https://github.com/yorukot/superfile
- **Dependencies:** None required by Core

## What is it?

Pretty fancy and modern terminal file manager

## How to use it?

Example from the official README:

```bash
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://superfile.dev/install.ps1'))"
```

Full documentation: https://superfile.dev

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `spf`

### `--help` output

```text
Usage: spf [COMMAND] [OPTIONS] [PATH]...

Pretty fancy and modern terminal file manager

Commands:
  path-list, pl        Print the path to the configuration and directory
  help, h              Shows a list of commands or help for one command

Options:
  --debug-info, --di             Print debug information
  --fix-hotkeys, --fh            Adds any missing hotkeys to the hotkey config file
  --fix-config-file, --fch       Adds any missing fields to the config file
  --print-last-dir, --pld        Print the last dir to stdout on exit (to use for cd)
  --config-file, -c <value>      Specify the path to a different config file
  --hotkey-file, --hf <value>    Specify the path to a different hotkey file
  --chooser-file, --cf <value>   On trying to open any file, superfile will write to its path to this file, and exit
  --help, -h                     show help
  --version, -v                  print the version

Version: v1.6.0

Use "spf [COMMAND] --help" for more information about a command.
```

