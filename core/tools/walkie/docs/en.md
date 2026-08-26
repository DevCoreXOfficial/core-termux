## Package Information

- **Name:** Walkie
- **Tags:** ai, p2p, communication, mesh
- **Source:** https://github.com/vikasprogrammer/walkie
- **Dependencies:** nodejs

## What is it?

P2P communication for AI agents. No server. No setup. Just talk.

## How to use it?

### Quick start

### Chat between machines

Same channel name = same channel. That's it.

```bash
# Your laptop
walkie chat family

# Brother's laptop
walkie chat family

# Your server
walkie chat family
```

Type a message, hit Enter, everyone sees it. Identity defaults to your hostname, or set `WALKIE_ID=yourname`.

### AI agent that responds to messages

Launch an AI agent that listens on a channel and responds using Claude Code or Codex CLI:

```bash
# Start an agent (auto-detects claude or codex)
walkie agent mychannel

# Or pick explicitly
walkie agent mychannel --cli codex
walkie agent mychannel --cli claude --model haiku --name my-bot
```

Now anyone on that channel talks to your AI:

```bash
walkie chat mychannel
> hey, what's the weather API endpoint?
# agent responds automatically
```

The agent maintains conversation memory across messages.

### Programmatic usage (for agents)

```bash
walkie connect ops:mysecret
walkie send ops "task complete, results ready"
walkie read ops --wait
walkie watch ops:mysecret --exec 'echo $WALKIE_MSG'
```

### Commands

All channel args accept `channel:secret` format. No colon = secret defaults to channel name.

```
walkie chat <channel>                    Interactive chat. Same name = same room
walkie agent <channel>                   AI agent that responds via claude/codex
walkie connect <channel>                 Join a channel programmatically
walkie send <channel> "message"          Send a message (or pipe from stdin)
walkie read <channel>                    Read pending messages (--wait, --timeout)
walkie watch <channel>                   Stream messages (--pretty, --exec, --persist)
walkie web                               Browser chat UI (-p PORT, -c channel:secret)
walkie status                            Show active channels, peers & buffers
walkie leave <channel>                   Leave a channel
walkie stop                              Stop the daemon
```

## How it works

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `walkie`

### `--help` output

```text
Usage: walkie [options] [command]

P2P communication for AI agents. No server. No setup. Just talk.

Getting started:
  $ walkie chat mychannel                    Interactive chat (same name = same channel)
  $ walkie agent mychannel                   AI agent that responds via claude/codex
  $ walkie agent mychannel --cli codex       Use a specific AI CLI

Programmatic (for agents/scripts):
  $ walkie connect ops:secret                Connect to a channel
  $ walkie send ops "task done"              Send a message
  $ walkie read ops --wait                   Wait for a message
  $ walkie watch ops:secret --pretty         Stream messages in real-time

Identity:
  Set WALKIE_ID=yourname to choose your display name.
  Without it, 'chat' and 'agent' default to your hostname.

How it works:
  Channel + secret are hashed into a topic. Peers find each other via
  Hyperswarm DHT. All traffic is P2P encrypted (Noise protocol).
  A background daemon keeps connections alive between commands.

Docs: https://walkie.sh

Options:
  -V, --version                output the version number
  -h, --help                   display help for command

Commands:
  chat [options] <channel>     Interactive chat — same channel name = same
                               channel
  agent [options] <channel>    AI agent that listens and responds via claude or
                               codex
  pair [options] <channel>     Start two AI agents collaborating on a channel
                               (brain + executor)
  connect [options] <channel>  Connect to a channel (format: channel:secret)
  watch [options] <channel>    Stream messages from a channel (format:
                               channel:secret)
  send <channel> [message]     Send a message to a channel (reads from stdin if
                               no message given)
  read [options] <channel>     Read pending messages from a channel
  leave <channel>              Leave a channel
  status                       Show active channels and peers
  web [options]                Start web-based chat UI
  stop                         Stop the walkie daemon
  help [command]               display help for command
```


### Common commands

```bash
walkie chat family
walkie chat family
walkie chat family
walkie agent mychannel
walkie agent mychannel --cli codex
walkie agent mychannel --cli claude --model haiku --name my-bot
walkie chat mychannel
> hey, what's the weather API endpoint?
```

