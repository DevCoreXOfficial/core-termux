## Package Information

- **Name:** tree
- **Tags:** files, listing
- **Source:** https://github.com/Old-Man-Programmer/tree
- **Dependencies:** None required by Core

## What is it?

Recursive directory listing in a tree-like format

## How to use it?

See the project page for full usage.

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `tree`

### `--help` output

```text
usage: tree [-acdfghilnpqrstuvxACDFJQNSUX] [-L level [-R]] [-H [-]baseHREF]
	[-T title] [-o filename] [-P pattern] [-I pattern] [--gitignore]
	[--gitfile[=]file] [--matchdirs] [--metafirst] [--ignore-case]
	[--nolinks] [--hintro[=]file] [--houtro[=]file] [--inodes] [--device]
	[--sort[=]name] [--dirsfirst] [--filesfirst] [--filelimit[=]#] [--si]
	[--du] [--prune] [--charset[=]X] [--timefmt[=]format] [--fromfile]
	[--fromtabfile] [--fflinks] [--info] [--infofile[=]file] [--noreport]
	[--hyperlink] [--scheme[=]schema] [--authority[=]host] [--opt-toggle]
	[--compress[=]#] [--condense] [--version] [--help] [--acl] [--selinux]
	[--] [directory ...]
  ------- Listing options -------
  -a            All files are listed.
  -d            List directories only.
  -l            Follow symbolic links like directories.
  -f            Print the full path prefix for each file.
  -x            Stay on current filesystem only.
  -L level      Descend only level directories deep.
  -R            Rerun tree when max dir level reached.
  -P pattern    List only those files that match the pattern given.
  -I pattern    Do not list files that match the given pattern.
  --gitignore   Filter by using .gitignore files.
  --gitfile X   Explicitly read a gitignore file.
  --ignore-case Ignore case when pattern matching.
  --matchdirs   Include directory names in -P pattern matching.
  --metafirst   Print meta-data at the beginning of each line.
  --prune       Prune empty directories from the output.
  --info        Print information about files found in .info files.
  --infofile X  Explicitly read info file.
  --noreport    Turn off file/directory count at end of tree listing.
  --charset X   Use charset X for terminal/HTML and indentation line output.
  --filelimit # Do not descend dirs with more than # files in them.
  --condense    Condense directory singletons to a single line of output.
  -o filename   Output to file instead of stdout.
  ------- File options -------
  -q            Print non-printable characters as '?'.
  -N            Print non-printable characters as is.
  -Q            Quote filenames with double quotes.
  -p            Print the protections for each file.
  -u            Displays file owner or UID number.
  -g            Displays file group owner or GID number.
  -s            Print the size in bytes of each file.
  -h            Print the size in a more human readable way.
  --si          Like -h, but use in SI units (powers of 1000).
  --du          Compute size of directories by their contents.
  -D            Print the date of last modification or (-c) status change.
  --timefmt fmt Print and format time according to the format fmt.
  -F            Appends '/', '=', '*', '@', '|' or '>' as per ls -F.
  --inodes      Print inode number of each file.
  --device      Print device ID number to which each file belongs.
  --acl         Print permissions with a + if an ACL is present.
  --selinux     Print the selinux security label if present.
  ------- Sorting options -------
  -v            Sort files alphanumerically by version.
  -t            Sort files by last modification time.
  -c            Sort files by last status change time.
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show tree:es`.
