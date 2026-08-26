## Package Information

- **Name:** LSD
- **Tags:** ls, files, icons
- **Project:** https://github.com/lsd-rs/lsd
- **Source:** https://github.com/lsd-rs/lsd
- **Dependencies:** None required by Core

## What is it?

The next gen ls command

## How to use it?

Example from the official README:

```bash
The alias above will replace a stock ls command with an lsd command without additional parameters.

Some examples of other useful aliases are:
```

Full documentation: https://github.com/lsd-rs/lsd

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `lsd`

### `--help` output

```text
An ls command with a lot of pretty colors and some other stuff.

Usage: lsd [OPTIONS] [FILE]...

Arguments:
  [FILE]...  [default: .]

Options:
  -a, --all                          Do not ignore entries starting with .
  -A, --almost-all                   Do not list implied . and ..
      --color <MODE>                 When to use terminal colours [default: auto] [possible values:
                                     always, auto, never]
      --icon <MODE>                  When to print the icons [default: auto] [possible values:
                                     always, auto, never]
      --icon-theme <THEME>           Whether to use fancy or unicode icons [default: fancy]
                                     [possible values: fancy, unicode]
  -F, --classify                     Append indicator (one of */=>@|) at the end of the file names
  -l, --long                         Display extended file metadata as a table
      --ignore-config                Ignore the configuration file
      --config-file <PATH>           Provide a custom lsd configuration file
  -1, --oneline                      Display one entry per line
  -R, --recursive                    Recurse into directories
  -h, --human-readable               For ls compatibility purposes ONLY, currently set by default
      --tree                         Recurse into directories and present the result as a tree
      --depth <NUM>                  Stop recursing into directories after reaching specified depth
  -d, --directory-only               Display directories themselves, and not their contents
                                     (recursively when used with --tree)
      --permission <MODE>            How to display permissions [default: rwx for linux, attributes
                                     for windows] [possible values: rwx, octal, attributes, disable]
      --size <MODE>                  How to display size [default: default] [possible values:
                                     default, short, bytes]
      --total-size                   Display the total size of directories
      --date <DATE>                  How to display date [default: date] [possible values: date,
                                     locale, relative, +date-time-format]
  -t, --timesort                     Sort by time modified
  -S, --sizesort                     Sort by size
  -X, --extensionsort                Sort by file extension
  -G, --gitsort                      Sort by git status
  -v, --versionsort                  Natural sort of (version) numbers within text
      --sort <TYPE>                  Sort by TYPE instead of name [possible values: size, time,
                                     version, extension, git, none]
  -U, --no-sort                      Do not sort. List entries in directory order
  -r, --reverse                      Reverse the order of the sort
      --group-dirs <MODE>            Sort the directories then the files [possible values: none,
                                     first, last]
      --group-directories-first      Groups the directories at the top before the files. Same as
                                     --group-dirs=first
      --blocks <BLOCKS>              Specify the blocks that will be displayed and in what order
                                     [possible values: permission, user, group, context, size, date,
                                     name, inode, links, git]
      --classic                      Enable classic mode (display output similar to ls)
      --no-symlink                   Do not display symlink target
  -I, --ignore-glob <PATTERN>        Do not display files/directories with names matching the glob
                                     pattern(s). More than one can be specified by repeating the
                                     argument
```


### Common commands

```bash
The alias above will replace a stock ls command with an lsd command without additional parameters.
Some examples of other useful aliases are:
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show lsd:es`.
