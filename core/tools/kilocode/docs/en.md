## Package Information

- **Name:** KiloCode CLI
- **Tags:** ai, agent, coding
- **Project:** https://kilocode.ai
- **Source:** https://github.com/Kilo-Org/kilocode
- **Dependencies:** nodejs

## What is it?

Kilo is the all-in-one agentic engineering platform. Build, ship, and iterate faster with the most popular open source coding agent.

## How to use it?

Example from the official README:

```bash
kilo run --auto "run tests and fix any failures"
```

Full documentation: https://kilocode.ai

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `kilo`

### `--help` output

```text
INFO  2026-08-26T04:42:48 +242ms service=default version=7.4.23 command=--help process_role=main run_id=d0354513-e65c-4dde-9ae8-a3191511ed1e opencode
██  ██ ██🬺🬏   ██  ██   ██🬺🬏     ████ ██     ██🬺🬏
████🬺🬏 ~~██   ██  ~~ ██~~██   ██~~~~ ██     ~~██
██  ██ ██████ 🬁🬬████ 🬁🬬██~~   🬁🬬████ 🬁🬬████ ██████
~~  ~~ ~~~~~~   ~~~~   ~~       ~~~~   ~~~~ ~~~~~~

Commands:
  kilo completion          generate shell completion script
  kilo acp                 start ACP (Agent Client Protocol) server
  kilo mcp                 manage MCP (Model Context Protocol) servers
  kilo [project]           start kilo tui                                                  [default]
  kilo attach <url>        attach to a running kilo server
  kilo run [message..]     run kilo with a message
  kilo debug               debugging and troubleshooting tools
  kilo auth                manage AI providers and credentials                  [aliases: providers]
  kilo agent               manage agents
  kilo upgrade [target]    upgrade kilo to the latest or a specific version
  kilo uninstall           uninstall kilo and remove all related files
  kilo serve               starts a headless kilo server
  kilo models [provider]   list all available models
  kilo stats               show token usage and cost statistics
  kilo export [sessionID]  export session data as JSON
  kilo import <file>       import session data from JSON file or URL
  kilo github              manage GitHub agent
  kilo pr                  manage pull requests
  kilo session             manage sessions
  kilo plugin <module>     install plugin and update config                          [aliases: plug]
  kilo db                  database tools
  kilo console             open or stop the local Kilo Console (deprecated)
  kilo cloud               run Cloud Agent tasks
  kilo roll-call <filter>  batch-test text models matching a filter for connectivity and latency
  kilo profile             show Kilo account profile
  kilo remote              enable remote connection for real-time session relay
  kilo daemon              manage the local kilo daemon
  kilo config              configuration tools
  kilo worktree            manage git worktrees
  kilo help [command]      show full CLI reference

Positionals:
  project  path to start kilo in                                                            [string]

Options:
  -h, --help          show help                                                            [boolean]
  -v, --version       show version number                                                  [boolean]
      --print-logs    print logs to stderr                                                 [boolean]
      --log-level     log level                 [string] [choices: "DEBUG", "INFO", "WARN", "ERROR"]
      --pure          run without external plugins                                         [boolean]
      --port          port to listen on                                        [number] [default: 0]
      --hostname      hostname to listen on                          [string] [default: "127.0.0.1"]
      --mdns          enable mDNS service discovery (defaults hostname to 0.0.0.0)
                                                                          [boolean] [default: false]
      --mdns-domain   custom domain name for mDNS service (default: kilo.local)
                                                                    [string] [default: "kilo.local"]
      --cors          additional domains to allow for CORS                     [array] [default: []]
  -m, --model         model to use in the format of provider/model                          [string]
```


### Common commands

```bash
kilo run --auto "run tests and fix any failures"
```
## Notes

- Supported platforms: see manifest.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show kilocode:es`.
