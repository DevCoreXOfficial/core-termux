## Package Information

- **Name:** shfmt
- **Tags:** format, shell, bash
- **Project:** https://github.com/mvdan/sh
- **Source:** https://github.com/mvdan/sh
- **Dependencies:** None required by Core

## What is it?

A shell parser, formatter, and interpreter with bash and zsh support; includes shfmt

## How to use it?

### Quick start

To parse shell scripts, inspect them, and print them out,
see the [syntax package](https://pkg.go.dev/mvdan.cc/sh/v3/syntax).

For high-level operations like performing shell expansions on strings,
see the [shell package](https://pkg.go.dev/mvdan.cc/sh/v3/shell).

To interpret or run shell scripts,
see the [interp package](https://pkg.go.dev/mvdan.cc/sh/v3/interp).

### shfmt

	go install mvdan.cc/sh/v3/cmd/shfmt@latest

`shfmt` formats shell programs. See [canonical.sh](syntax/canonical.sh) for a
quick look at its default style. For example:

	shfmt -l -w script.sh

For more information, see [its manpage](cmd/shfmt/shfmt.1.scd), which can be
viewed directly as Markdown or rendered with [scdoc].

Packages are available on [Alpine], [Arch], [Debian], [Docker], [Fedora], [FreeBSD],
[Homebrew], [MacPorts], [NixOS], [OpenSUSE], [Scoop], [Snapcraft], [Void] and [webi].

### Sponsoring

If this project saves you or your company time, consider
[sponsoring me on GitHub](https://github.com/sponsors/mvdan).
Monthly tiers include benefits like your logo on a README,
prioritized issues, or direct support in your company's chat app.
One-time tiers offer a call about one of my projects
or a Go consulting or mentorship session.

### Contributing

Bug reports and feature requests should be filed as detailed issues,
ideally with an example which reproduces the bug or shows what feature you're after.

Unless you're an active user or contributor to the project, drive-by AI patches
are not helpful. File detailed issues instead.

### Caveats

* When indexing Bash associative arrays, always use quotes. The static parser
  will otherwise have to assume that the index is an arithmetic expression.

```sh
$ echo '${array[spaced string]}' | shfmt
<standard input>:1:16: not a valid arithmetic operator: `string`
$ echo '${array[weird!key]}' | shfmt
<standard input>:1:8: reached `!` without matching `[` with `]`
$ echo '${array[dash-string]}' | shfmt
${array[dash - string]}
```

* `$((` and `((` ambiguity is not supported. Backtracking would complicate the
  parser and make streaming support via `io.Reader` impossible. The POSIX spec
  recommends to [space the operands][posix-ambiguity] if `$( (` is meant.

```sh
$ echo '$((foo); (bar))' | shfmt
1:1: reached ) without matching $(( with ))
```

* `export`, `let`, and `declare` are parsed as keywords.

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `shfmt`

### `--help` output

```text
usage: shfmt [flags] [path ...]

shfmt formats shell programs. If the only argument is a dash ('-') or no
arguments are given, standard input will be used. If a given path is a
directory, all shell scripts found under that directory will be used.

  --version  show version and exit

  -l[=0], --list[=0]  error with a list of files whose formatting differs from shfmt;
                      paths are separated by a newline or a null character if -l=0
  -w,     --write     write result to file instead of stdout
  -d,     --diff      error with a diff when the formatting differs
  --apply-ignore      always apply EditorConfig ignore rules
  --filename str      provide a name for the standard input file

Parser options:

  -ln, --language-dialect str  bash/posix/mksh/bats/zsh, default "auto"
  -p,  --posix                 shorthand for -ln=posix
  -s,  --simplify              simplify the code

Printer options:

  -i,  --indent uint       0 for tabs (default), >0 for number of spaces
  -bn, --binary-next-line  binary ops like && and | may start a line
  -ci, --case-indent       switch cases will be indented
  -sr, --space-redirects   redirect operators will be followed by a space
  -kp, --keep-padding      keep column alignment paddings
  -fn, --func-next-line    function opening braces are placed on a separate line
  -mn, --minify             minify the code to reduce its size (implies -s)

Utilities:

  -f[=0], --find[=0]  recursively find all shell files and print the paths;
                      paths are separated by a newline or a null character if -f=0
  --to-json           print syntax tree to stdout as a typed JSON
  --from-json         read syntax tree from stdin as a typed JSON

Formatting options can also be read from EditorConfig files; see 'man shfmt'
for a detailed description of the tool's behavior.
For more information and to report bugs, see https://github.com/mvdan/sh.
```


### Common commands

```bash
$ echo '${array[spaced string]}' | shfmt
<standard input>:1:16: not a valid arithmetic operator: `string`
$ echo '${array[weird!key]}' | shfmt
<standard input>:1:8: reached `!` without matching `[` with `]`
$ echo '${array[dash-string]}' | shfmt
${array[dash - string]}
1:1: reached ) without matching $(( with ))
```

