## Package Information

- **Name:** ncurses-utils
- **Tags:** tput, terminal
- **Dependencies:** None required by Core

## What is it?

Terminal UI manipulation utilities

Full documentation: project page

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `tput`

### `--help` output

```text
tput: invalid option -- -
Usage: tput [options] [command]

Options:
  -S <<       read commands from standard input
  -T TERM     use this instead of $TERM
  -V          print curses-version
  -v          verbose, show warnings
  -x          do not try to clear scrollback

Commands:
  clear       clear the screen
  init        initialize the terminal
  reset       reinitialize the terminal
  capname     unlike clear/init/reset, print value for capability "capname"
```

