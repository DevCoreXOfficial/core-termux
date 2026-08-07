# SuperFile

Terminal file manager with TUI, themes, and hotkeys

**Package:** spf
**Author:** DevCoreX
**Repository:** https://github.com/DevCoreXOfficial/core-termux
**Official:** https://github.com/yorukot/superfile
**Type:** Development tool (compiled from source)
**License:** MIT

## Description

SuperFile (spf) is a modern terminal-based file manager written in Go. It features a multi-panel layout, file and image previews, Vim-style navigation, theming support, and a fully configurable hotkey system. It is designed to replace traditional CLI file management with a fast, visual, and keyboard-driven workflow.

## Requirements

- A terminal with a **Nerd Font** installed and configured (required for icons to render correctly)
- Neovim (optional, for editor integration)

## Neovim Integration

### Opening files from spf in Neovim (spf → nvim)

Edit the superfile configuration file (run `spf pl` to see the exact path; typically `~/.config/superfile/config.toml`):

```toml
editor = "nvim"
```

With this set:
- `e` opens the selected file in nvim
- `E` (shift+e) opens the current directory in nvim as a directory-aware editor

> **Note:** there is a known issue where nvim opens with the cursor in the correct folder, but the working directory (`cwd`) stays fixed to the parent. If you use plugins like `oil.nvim` or `nvim-tree`, verify the `cwd` is what you expect.

### Opening spf from inside Neovim (nvim → spf)

Useful for a quick file picker without leaving the editor. Plugin: `Superfile.nvim`.

With `lazy.nvim`:

```lua
{
  "anaypurohit0907/superfile.nvim",
  main = "superfile",
  opts = { key = false },
  keys = {
    {
      "<C-s>", -- change to your preferred keybind
      function() require("superfile").open() end,
      mode = { "n", "t" },
      desc = "Open/Focus Superfile",
      silent = true,
    },
  },
}
```

Install the plugin in your nvim config and run `:Lazy sync`.

## Startup Commands

| Action | Command |
|---|---|
| Open spf in current directory | `spf` |
| Open spf in a specific path | `spf {path}` |
| Open spf with multiple paths (multiple panels) | `spf {path1} {path2} ...` |
| Show config, hotkeys, logs, and data paths | `spf pl` (path-list) |
| Repair hotkeys.toml by adding missing keys | `spf --fh` |
| Repair config.toml by adding missing entries | `spf --fch` |

## General Hotkeys

| Function | Key |
|---|---|
| Open superfile | `spf` |
| Confirm selected item | `enter`, `right`, `l` |
| Exit typing, modal, or spf | `q`, `esc` |
| Quit spf and `cd` into current directory | `Q` (requires `cd_on_quit` enabled in config) |
| Confirm typing | `enter` |
| Cancel typing | `ctrl+c`, `esc` |
| Open help menu (hotkey list) | `?` |
| Open prompt in shell mode | `:` |
| Open prompt in spf mode | `>` |
| Open zoxide navigation | `z` |

## Panel Navigation

| Function | Key |
|---|---|
| Create new file panel | `n` |
| Split the focused panel | `N` (shift+n) |
| Close the focused panel | `w` |
| Toggle preview panel | `f` |
| Open sort options menu | `o` |
| Reverse sort order | `R` (shift+r) |
| Toggle footer | `F` (shift+f) |
| Focus next panel | `tab`, `L` (shift+l) |
| Focus previous panel | `shift+left`, `H` (shift+h) |
| Focus process bar | `p` |
| Focus sidebar | `s` |
| Focus metadata panel | `m` |

## Movement Within a Panel

| Function | Key |
|---|---|
| Move up | `up`, `k` |
| Move down | `down`, `j` |
| Page up / down | `pgup` / `pgdown` |
| Go to parent directory | `h`, `left`, `backspace` |
| Select all items (selection mode) | `A` (shift+a) |
| Select upward from cursor | `shift+up`, `K` (shift+k) |
| Select downward from cursor | `shift+down`, `J` (shift+j) |
| Toggle hidden files | `.` |
| Activate search bar | `/` |
| Toggle between selection mode and normal mode | `v` |
| Pin/unpin directory to sidebar | `P` (shift+p) |

## File Operations

| Function | Key |
|---|---|
| Create file or folder (end with `/` for a folder) | `ctrl+n` |
| Rename file or folder | `ctrl+r` |
| Copy selected items to clipboard | `ctrl+c` |
| Cut selected items | `ctrl+x` |
| Paste items from clipboard | `ctrl+v`, `ctrl+w` |
| Delete selected items | `ctrl+d`, `delete` |
| Permanently delete | `D` (shift+d) |
| Copy path of current/selected file or directory | `ctrl+p` |
| Copy current working directory | `c` |
| Extract compressed file | `ctrl+e` |
| Compress file or folder to .zip | `ctrl+a` |
| Open file with default editor | `e` |
| Open current directory with default editor | `E` (shift+e) |

## Typical Workflow

1. Open `spf` in your project directory.
2. Split the panel with `N` to have two locations visible at once.
3. Enter selection mode with `v` and mark multiple files with `shift+down`.
4. Copy them with `ctrl+c`.
5. Switch panels with `tab`.
6. Paste with `ctrl+v`.
7. To edit something directly, press `e` to open it in Neovim.

## Configuration Files

Run `spf pl` to see the exact paths. On Termux, these are typically:

- `~/.config/superfile/config.toml` — general behavior (editor, theme, `cd_on_quit`, previews, etc.)
- `~/.config/superfile/hotkeys.toml` — remapping of any hotkey

> Back up `hotkeys.toml` before editing it.

## Official Resources

- Website: https://superfile.dev
- Full hotkey list: https://superfile.dev/list/hotkey-list/
- Repository: https://github.com/yorukot/superfile
