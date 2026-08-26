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

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show walkie:es`.
