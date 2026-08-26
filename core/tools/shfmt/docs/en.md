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

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show shfmt:es`.
