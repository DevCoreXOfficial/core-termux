## Package Information

- **Name:** Bat
- **Tags:** cat, syntax, paging
- **Project:** https://github.com/sharkdp/bat
- **Source:** https://github.com/sharkdp/bat
- **Dependencies:** None required by Core

## What is it?

A cat(1) clone with wings.

## How to use it?

### Configuration file

`bat` can also be customized with a configuration file. The location of the file is dependent
on your operating system. To get the default path for your system, call
```bash
bat --config-file
```

Alternatively, you can use `BAT_CONFIG_PATH` or `BAT_CONFIG_DIR` environment variables to point `bat`
to a non-default location of the configuration file or the configuration directory respectively:
```bash
export BAT_CONFIG_PATH="/path/to/bat/bat.conf"
export BAT_CONFIG_DIR="/path/to/bat"
```

A default configuration file can be created with the `--generate-config-file` option.
```bash
bat --generate-config-file
```

There is also now a systemwide configuration file, which is located under `/etc/bat/config` on
Linux and Mac OS and `C:\ProgramData\bat\config` on windows. If the system wide configuration
file is present, the content of the user configuration will simply be appended to it.

### Format

The configuration file is a simple list of command line arguments. Use `bat --help` to see a full list of possible options and values. In addition, you can add comments by prepending a line with the `#` character.

Example configuration file:
```bash
# Set the theme to "TwoDark"
--theme="TwoDark"

# Show line numbers, Git modifications and file header (but no grid)
--style="numbers,changes,header"

# Use italic text on the terminal (not supported on all terminals)
--italic-text=always

# Use C++ syntax for Arduino .ino files
--map-syntax "*.ino:C++"
```

## Using `bat` on Windows

`bat` mostly works out-of-the-box on Windows, but a few features may need extra configuration.

### Prerequisites

You will need to install the [Visual C++ Redistributable](https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads) package.

### Paging

Windows only includes a very limited pager in the form of `more`. You can download a Windows binary
for `less` [from its homepage](http://www.greenwoodsoftware.com/less/download.html) or [through
Chocolatey](https://chocolatey.org/packages/Less). To use it, place the binary in a directory in
your `PATH` or [define an environment variable](#using-a-different-pager). The [Chocolatey package](#on-windows) installs `less` automatically.

### Colors

Windows 10 natively supports colors in both `conhost.exe` (Command Prompt) and PowerShell since
[v1511](https://en.wikipedia.org/wiki/Windows_10_version_history#Version_1511_(November_Update)), as
well as in newer versions of bash. On earlier versions of Windows, you can use
[Cmder](http://cmder.app/), which includes [ConEmu](https://conemu.github.io/).

**Note:** Old versions of `less` do not correctly interpret colors on Windows. To fix this, you can add the optional Unix tools to your PATH when installing Git. If you don’t have any other pagers installed, you can disable paging entirely by passing `--paging=never` or by setting `BAT_PAGER` to an empty string.

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `bat` (aliases: `batcat`)

### `--help` output

```text
A cat(1) clone with syntax highlighting and Git integration.

Usage: bat [OPTIONS] [FILE]...
       bat <COMMAND>

Arguments:
  [FILE]...
          File(s) to print / concatenate. Use a dash ('-') or no argument at all to read from
          standard input.

Options:
  -A, --show-all
          Show non-printable characters like space, tab or newline. This option can also be used to
          print binary files. Use '--tabs' to control the width of the tab-placeholders.

      --nonprintable-notation <notation>
          Set notation for non-printable characters.

          Possible values:
            * unicode (␇, ␊, ␀, ..)
            * caret   (^G, ^J, ^@, ..)

      --binary <behavior>
          How to treat binary content. (default: no-printing)

          Possible values:
            * no-printing: do not print any binary content
            * as-text: treat binary content as normal text

  -p, --plain...
          Only show plain style, no decorations. This is an alias for '--style=plain'. When '-p' is
          used twice ('-pp'), it also disables automatic paging (alias for '--style=plain
          --paging=never').

  -l, --language <language>
          Explicitly set the language for syntax highlighting. The language can be specified as a
          name (like 'C++' or 'LaTeX') or possible file extension (like 'cpp', 'hpp' or 'md'). Use
          '--list-languages' to show all supported language names and file extensions.

  -H, --highlight-line <N:M>
          Highlight the specified line ranges with a different background color For example:
            '--highlight-line 40' highlights line 40
            '--highlight-line 30:40' highlights lines 30 to 40
            '--highlight-line :40' highlights lines 1 to 40
            '--highlight-line 40:' highlights lines 40 to the end of the file
            '--highlight-line 30:+10' highlights lines 30 to 40

      --file-name <name>
          Specify the name to display for a file. Useful when piping data to bat from STDIN when bat
          does not otherwise know the filename. Note that the provided file name is also used for
          syntax detection.

  -d, --diff
          Only show lines that have been added/removed/modified with respect to the Git index. Use
          --diff-context=N to control how much context you want to see.
```


### Common commands

```bash
bat --config-file
export BAT_CONFIG_PATH="/path/to/bat/bat.conf"
export BAT_CONFIG_DIR="/path/to/bat"
bat --generate-config-file
--theme="TwoDark"
--style="numbers,changes,header"
--italic-text=always
--map-syntax "*.ino:C++"
```

