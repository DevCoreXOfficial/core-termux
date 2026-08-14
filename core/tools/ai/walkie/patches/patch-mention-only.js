#!/data/data/com.termux/files/usr/bin/env node
// walkie patch: strict solo-tag mode for `walkie agent`
//
// Applied by hand after install (same pattern as patch-agents.js).
// Idempotent: a marker comment is inserted on first run, and a subsequent
// run exits early. Each replacement is checked against its exact anchor
// string; if any anchor is missing the patch fails loudly instead of
// shipping a broken install.
//
// Features:
//   - --mention-only  : the agent responds ONLY when @mentioned by name.
//     Without this flag walkie still responds to messages with no mentions
//     at all, which would let an agent interfere in human-to-human chat.
//   - --respond-to <id>: the agent responds ONLY to messages from that
//     sender (e.g. an executor that must only obey the brain).
//   - Anti-replay      : messages older than agent start (START_TS) are
//     dropped, so a daemon restart can never re-trigger old tasks.
//
// Usage: node patch-mention-only.js <path-to-walkie.js>

const fs = require('fs')

const target = process.argv[2]
if (!target) {
  console.error('walkie-patch: missing walkie.js path argument')
  process.exit(1)
}

const MARKER = '/* walkie-patch-mention */'

const replacements = [
  {
    name: 'add --mention-only and --respond-to options',
    from: `  .option('--skip-git-repo-check', 'Skip the git repository check (only forwarded to agents that support it, e.g. codex)')`,
    to: `  .option('--skip-git-repo-check', 'Skip the git repository check (only forwarded to agents that support it, e.g. codex)')
  .option('--mention-only', 'Respond only when this agent is @mentioned (strict tag mode)')
  .option('--respond-to <id>', 'Respond only to messages from this sender (e.g. executor that only obeys the brain)')`
  },
  {
    name: 'add START_TS anti-replay baseline',
    from: `      let lastSender = null
      let consecutiveCount = 0
      const MAX_CONSECUTIVE = 10`,
    to: `      let lastSender = null
      let consecutiveCount = 0
      const MAX_CONSECUTIVE = 10
      // Anti-replay: drop anything older than agent start (daemon-restart guard)
      const START_TS = Date.now()`
  },
  {
    name: 'strict mention-only + trusted-sender + anti-replay filters',
    from: `        // @mention filtering: if directed at someone else, ignore
        const mentions = (msg.data.match(/@([\\w-]+)/g) || []).map(m => m.slice(1))
        if (mentions.length > 0 && !mentions.includes(agentName)) return`,
    to: `        // @mention filtering: if directed at someone else, ignore
        const mentions = (msg.data.match(/@([\\w-]+)/g) || []).map(m => m.slice(1))
        if (mentions.length > 0 && !mentions.includes(agentName)) return
        // ${MARKER} strict mode: respond ONLY when this agent is @mentioned
        if (opts.mentionOnly && !mentions.includes(agentName)) return
        // trusted sender: respond ONLY to messages from that sender
        if (opts.respondTo && msg.from !== opts.respondTo) return
        // anti-replay: drop messages from before the agent started
        if (msg.ts && msg.ts < START_TS) return`
  }
]

let src
try {
  src = fs.readFileSync(target, 'utf8')
} catch (e) {
  console.error('walkie-patch: cannot read ' + target + ': ' + e.message)
  process.exit(1)
}

if (src.includes(MARKER)) {
  console.log('walkie-patch: already applied, skipping')
  process.exit(0)
}

for (const r of replacements) {
  if (!src.includes(r.from)) {
    console.error('walkie-patch: FAILED to apply "' + r.name + '" — anchor not found in ' + target)
    process.exit(1)
  }
  src = src.split(r.from).join(r.to)
}

fs.writeFileSync(target, src)
console.log('walkie-patch: strict mention-only mode applied to ' + target)
