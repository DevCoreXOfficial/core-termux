## Package Information

- **Name:** Bun
- **Tags:** language, runtime, javascript, typescript
- **Project:** https://bun.sh
- **Source:** https://github.com/oven-sh/bun
- **Dependencies:** None required by Core

## What is it?

Incredibly fast JavaScript runtime, bundler, test runner, and package manager – all in one

## How to use it?

Example from the official README:

```bash
bun run index.tsx             # TS and JSX supported out-of-the-box
```

Full documentation: https://bun.sh

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `bun`

### `--help` output

```text
Bun is a fast JavaScript runtime, package manager, bundler, and test runner. (1.4.0+34cbb9a40)

Usage: bun <command> [...flags] [...args]

Commands:
  run       ./my-script.ts       Execute a file with Bun
            lint                 Run a package.json script
  test                           Run unit tests with Bun
  x         vite                 Execute a package binary (CLI), installing if needed (bunx)
  repl                           Start a REPL session with Bun
  exec                           Run a shell script directly with Bun

  install                        Install dependencies for a package.json (bun i)
  add       hono                 Add a dependency to package.json (bun a)
  remove    left-pad             Remove a dependency from package.json (bun rm)
  update    react                Update outdated dependencies
  audit                          Check installed packages for vulnerabilities
  dedupe                         Remove duplicate versions from the lockfile
  prune                          Remove packages that are not in the lockfile from node_modules
  outdated                       Display latest versions of outdated dependencies
  link      [<package>]          Register or link a local npm package
  unlink                         Unregister a local npm package
  publish                        Publish a package to the npm registry
  patch <pkg>                    Prepare a package for patching
  pm <subcommand>                Additional package management utilities
  info      lyra                 Display package metadata from the registry
  why       @remix-run/dev       Explain why a package is installed

  build     ./a.ts ./b.jsx       Bundle TypeScript & JavaScript into a single file

  init                           Start an empty Bun project from a built-in template
  create    elysia               Create a new project from a template (bun c)
  upgrade                        Upgrade to latest version of Bun.

  <command> --help               Print help text for command.

Flags:
      --silent                        Don't print the script command
      --elide-lines=<val>             Number of lines of script output shown when using --filter (default: 10). Set to 0 to show all lines.
  -v, --version                       Print version and exit
      --revision                      Print version with revision and exit
  -F, --filter=<val>                  Run a script in all workspace packages matching the pattern
  -b, --bun                           Force a script or package to use Bun's runtime instead of Node.js (via symlinking node)
      --no-orphans                    Exit when the parent process dies, and on exit kill every descendant.
      --shell=<val>                   Control the shell used for package.json scripts. Supports either 'bun' or 'system'
      --workspaces                    Run a script in all workspace packages (from the "workspaces" field in package.json)
      --parallel                      Run multiple scripts concurrently with Foreman-style output
      --sequential                    Run multiple scripts sequentially with Foreman-style output
      --no-exit-on-error              Continue running other scripts when one fails (with --parallel/--sequential)
      --watch                         Automatically restart the process on file change
      --watch-kill-signal=<val>       Signal whose handlers run when --watch restarts the process (default: "SIGTERM")
      --hot                           Enable auto reload in the Bun runtime, test runner, or bundler
      --no-clear-screen               Disable clearing the terminal screen on reload when --hot or --watch is enabled
      --smol                          Use less memory, but run garbage collection more often
      --interactive                   Start a Node.js-compatible REPL, like node --interactive
```


### Common commands

```bash
bun run index.tsx             # TS and JSX supported out-of-the-box
```

