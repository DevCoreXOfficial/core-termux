#!/data/data/com.termux/files/usr/bin/env node
// walkie patch: channel member tracking for `walkie agent`
//
// Applied by hand after install (same pattern as patch-agents.js /
// patch-mention-only.js). Idempotent: a marker comment is inserted on first
// run, and a subsequent run exits early. Each replacement is checked against
// its exact anchor string; if any anchor is missing the patch fails loudly.
//
// Features (opt-in via `--track-members`):
//   - Keeps an in-memory roster of channel participants:
//       * local subscribers are picked up from the daemon's `"X joined"` /
//         `"X left"` system announcements, plus a `members` query at startup;
//       * remote peers (agents/humans on other devices) are registered from
//         the `from` id of the first message they send to the channel.
//   - Injects the current roster into the agent prompt ONLY when membership
//     changed since the last processed message (Δ-based, zero noise otherwise),
//     so a "brain" agent always knows which executors/humans are present and
//     can delegate to the right one.
//   - Persists the roster to `<WALKIE_DIR|~/.walkie>/roster-<channel>.json`
//     so membership survives agent/daemon restarts.
//
// Usage: node patch-members.js <path-to-walkie.js>

const fs = require('fs')
const path = require('path')
const os = require('os')

const target = process.argv[2]
if (!target) {
  console.error('walkie-patch: missing walkie.js path argument')
  process.exit(1)
}

const MARKER = '/* walkie-patch-members */'

const ROSTER_CODE = `      // ${MARKER} member tracking (opt-in via --track-members)
      const fs = require('fs')
      const path = require('path')
      const os = require('os')
      const ROSTER_FILE = path.join(process.env.WALKIE_DIR || path.join(os.homedir(), '.walkie'), 'roster-' + channel + '.json')
      const roster = new Map()        // id -> { firstSeen, lastSeen, left? }
      const rosterDelta = new Set()   // ids with membership change not yet exposed
      function rosterLoad() {
        try {
          const d = JSON.parse(fs.readFileSync(ROSTER_FILE, 'utf8'))
          for (const [k, v] of Object.entries(d || {})) roster.set(k, v)
        } catch {}
      }
      function rosterSave() {
        try {
          fs.mkdirSync(path.dirname(ROSTER_FILE), { recursive: true })
          fs.writeFileSync(ROSTER_FILE, JSON.stringify(Object.fromEntries(roster), null, 2))
        } catch (e) { console.error('[roster] save failed: ' + e.message) }
      }
      function rosterTouch(id, entered) {
        if (!id || id === cid || id === 'daemon') return
        const st = roster.get(id)
        if (!st) roster.set(id, { firstSeen: Date.now(), lastSeen: Date.now(), left: entered ? undefined : Date.now() })
        else {
          st.lastSeen = Date.now()
          if (entered) delete st.left
          else st.left = Date.now()
        }
        rosterDelta.add(id)
        rosterSave()
      }
      function rosterBlock() {
        if (roster.size === 0) return ''
        const now = Date.now()
        const active = [...roster.keys()].filter(id => {
          const st = roster.get(id)
          return !st.left || (now - st.left) < 60000
        }).sort()
        if (active.length === 0) return ''
        return '\\n\\n[ROSTER #' + channel + '] ' + active.map(id => roster.get(id).left ? id + ' (left)' : id).join(', ')
      }
      if (opts.trackMembers) {
        rosterLoad()
        rosterSave()
        ;(async () => {
          try {
            const m = await request({ action: 'members', channel, clientId: cid })
            if (m && m.ok) for (const id of m.members || []) rosterTouch(id, true)
          } catch {}
          rosterDelta.clear()
        })()
      }`

const replacements = [
  {
    name: 'add --track-members option',
    from: `  .option('--respond-to <id>', 'Respond only to messages from this sender (e.g. executor that only obeys the brain)')`,
    to: `  .option('--respond-to <id>', 'Respond only to messages from this sender (e.g. executor that only obeys the brain)')
  .option('--track-members', 'Track channel participants and expose the current roster in the agent prompt (Δ-based, persisted)')`
  },
  {
    name: 'add roster state (require + tracking code after START_TS)',
    from: `      // Anti-replay: drop anything older than agent start (daemon-restart guard)
      const START_TS = Date.now()`,
    to: `      // Anti-replay: drop anything older than agent start (daemon-restart guard)
      const START_TS = Date.now()
${ROSTER_CODE}`
  },
  {
    name: 'intercept joins/leaves/peer presence before generic filters',
    from: `      streamMessages(channel, secret, cid, abort, (msg) => {
        // Don't respond to own messages or system messages
        if (msg.from === cid || msg.from === 'system') return`,
    to: `      streamMessages(channel, secret, cid, abort, (msg) => {
        // ${MARKER} roster interception (before generic filters)
        if (opts.trackMembers && (!msg.ts || msg.ts >= START_TS)) {
          if (msg.from === 'system') {
            const j = /^(.+) joined$/.exec(msg.data)
            const l = /^(.+) left$/.exec(msg.data)
            if (j) rosterTouch(j[1], true)
            else if (l) rosterTouch(l[1], false)
          } else if (msg.from !== cid && msg.from !== 'daemon') {
            if (!roster.has(msg.from)) rosterTouch(msg.from, true)
            else roster.get(msg.from).lastSeen = Date.now()
          }
        }
        // Don't respond to own messages or system messages
        if (msg.from === cid || msg.from === 'system') return`
  },
  {
    name: 'inject roster block into the agent prompt (Δ-based)',
    from: `          const prompt = opts.prompt
            ? \`\${opts.prompt}\\n\\nMessage from \${msg.from}: \${msg.data}\`
            : \`You are "\${agentName}", an AI agent on a walkie P2P channel called "#\${channel}". Someone is talking to you. Be helpful and concise.\\n\\nMessage from \${msg.from}: \${msg.data}\``,
    to: `          const prompt = opts.prompt
            ? \`\${opts.prompt}\\n\\nMessage from \${msg.from}: \${msg.data}\`
            : \`You are "\${agentName}", an AI agent on a walkie P2P channel called "#\${channel}". Someone is talking to you. Be helpful and concise.\\n\\nMessage from \${msg.from}: \${msg.data}\`
          const rosterCtx = opts.trackMembers && rosterDelta.size > 0 ? rosterBlock() : ''
          if (rosterCtx) rosterDelta.clear()`
  },
  {
    name: 'append rosterCtx to the prompt passed to the runner',
    from: `          const out = await askFn(prompt, sessionId, opts.model, extraArgs)`,
    to: `          const out = await askFn(prompt + rosterCtx, sessionId, opts.model, extraArgs)`
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

fs.mkdirSync(path.dirname(target), { recursive: true })
const backup = target + '.bak-members'
if (!fs.existsSync(backup)) fs.copyFileSync(target, backup)
fs.writeFileSync(target, src)
console.log('walkie-patch: member tracking applied to ' + target)
console.log('walkie-patch: backup at ' + backup)