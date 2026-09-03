#!/usr/bin/env bash
# Platform: Termux / Android (requires the Termux bash path at runtime via wrappers).
[[ -n "$CORE_PATH" ]] || CORE_PATH="$HOME/.core/core"
source "$CORE_PATH/utils/bootstrap.sh"
CORE_TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # this platform folder
import "@/utils/env"


import "@/utils/log"
import "@/utils/colors"
import "@/utils/version"
import "@/utils/uninstall"

: "${CORE_CACHE:=$HOME/.cache/core-termux}"
: "${CORE_PATH:=$HOME/core-termux/core}"
: "${PREFIX:=/data/data/com.termux/files/usr}"

LOG_FILE="$CORE_CACHE/install_ai.log"
WALKIE_DATA_DIR="${WALKIE_DATA_DIR:-$HOME/.local/share/core-termux-data/walkie}"
WALKIE_PATCH_DIR="$CORE_TOOL_DIR/patches"
WALKIE_LAUNCHER="$CORE_TOOL_DIR/bin/walkie"
WALKIE_BIN="$PREFIX/bin/walkie"
WALKIE_DIR_CONFIG="$HOME/.walkie"

# walkie-sh source.
#   Default: git main (v1.5.0) — includes chat/agent/pair, not yet on npm.
#   Legacy:  walkie-sh@1.4.0 (npm registry) — set WALKIE_USE_140=1
WALKIE_SOURCE="github:vikasprogrammer/walkie"
WALKIE_140_SOURCE="walkie-sh@1.4.0"

_walkie_node() {
  if command -v node &>/dev/null; then
    command -v node
  else
    echo "$PREFIX/bin/node"
  fi
}

# Resolve the active walkie.js regardless of subshell boundaries.
_walkie_resolve_js() {
  local local_js="$WALKIE_DATA_DIR/node_modules/walkie-sh/bin/walkie.js"
  local global_js="$PREFIX/lib/node_modules/walkie-sh/bin/walkie.js"
  if [[ -x "$local_js" ]]; then
    echo "$local_js"
  elif [[ -x "$global_js" ]]; then
    echo "$global_js"
  fi
}

_walkie_install_type() {
  local js
  js=$(_walkie_resolve_js)
  case "$js" in
    "$PREFIX/lib/node_modules/"*) echo "global" ;;
    *) echo "local" ;;
  esac
}

# ===== DEPENDENCIES =====

_walkie_dependencies() {
  loading "Installing walkie dependencies" _walkie_dependencies_impl
}

_walkie_dependencies_impl() {
  declare -A DEPS=(
    ["nodejs-lts"]="node"
    ["git"]="git"
    ["curl"]="curl"
  )

  local pkg_name bin_name
  for pkg_name in "${!DEPS[@]}"; do
    bin_name="${DEPS[$pkg_name]}"
    if ! command -v "$bin_name" &>/dev/null; then
      if ! yes | pkg install "$pkg_name" &>>"$LOG_FILE"; then
        log_error "Failed to install $pkg_name"
        return 1
      fi
    fi
  done

  return 0
}

# ===== NPM INSTALL =====

# Local isolated install of walkie-sh into $WALKIE_DATA_DIR
# $1: npm dependency spec (e.g. "github:vikasprogrammer/walkie" or "walkie-sh@1.4.0")
_walkie_install_local() {
  local spec="$1"

  mkdir -p "$WALKIE_DATA_DIR"
  pushd "$WALKIE_DATA_DIR" &>/dev/null || return 1

  cat > package.json << EOF
{
  "name": "walkie-termux",
  "private": true,
  "version": "1.0.0",
  "dependencies": {
    "walkie-sh": "${spec}"
  }
}
EOF

  cat > .npmrc << 'NPMRCEOF'
foreground-scripts=true
script-shell=/data/data/com.termux/files/usr/bin/sh
allow-scripts=walkie-sh,udx-native,sodium-native
NPMRCEOF

  if ! npm install --production --no-audit --no-fund &>>"$LOG_FILE"; then
    log_warn "npm install failed, trying with --ignore-scripts..."
    npm install --production --no-audit --no-fund --ignore-scripts &>>"$LOG_FILE"
  fi

  popd &>/dev/null || true
  return 0
}

# Global shared install of walkie-sh into ${PREFIX}/lib/node_modules
# --no-bin-links: keep our launcher in ${PREFIX}/bin/walkie, don't let npm
# create its own symlink over it.
# $1: npm dependency spec
_walkie_install_global() {
  local spec="$1"

  if ! npm install -g "$spec" --no-audit --no-fund --no-bin-links --allow-scripts=walkie-sh,udx-native,sodium-native &>>"$LOG_FILE"; then
    log_warn "npm install failed, trying with --ignore-scripts..."
    npm install -g "$spec" --no-audit --no-fund --no-bin-links --allow-scripts=walkie-sh,udx-native,sodium-native --ignore-scripts &>>"$LOG_FILE"
  fi
}

# Generic installer: local first, fallback to global on failure.
# Sets $_WALKIE_INSTALL_TYPE to local|global and resolves $_WALKIE_JS.
_walkie_install_pkg() {
  loading "Installing walkie-sh (this may take a while)" _walkie_install_pkg_impl
}

_walkie_install_pkg_impl() {
  local spec="$WALKIE_SOURCE"
  local global_dir="$PREFIX/lib/node_modules"
  local local_js="$WALKIE_DATA_DIR/node_modules/walkie-sh/bin/walkie.js"
  local global_js="$global_dir/walkie-sh/bin/walkie.js"

  if [[ "${WALKIE_USE_140:-0}" == "1" ]]; then
    spec="$WALKIE_140_SOURCE"
    log_info "Legacy mode: installing walkie-sh 1.4.0 from npm registry"
  fi

  if [[ "${WALKIE_INSTALL_GLOBAL:-0}" == "1" ]]; then
    _walkie_install_global "$spec"
    if [[ ! -x "$global_js" ]]; then
      log_error "Global installation failed. No walkie binary found."
      return 1
    fi
    return 0
  fi

  _walkie_install_local "$spec"
  if [[ ! -x "$local_js" ]]; then
    log_warn "Local installation failed (possible architecture conflict)."
    log_warn "Falling back to GLOBAL installation..."
    _walkie_install_global "$spec"
    if [[ ! -x "$global_js" ]]; then
      log_error "Global installation failed. No walkie binary found."
      return 1
    fi
    return 0
  fi

  return 0
}

# ===== PATCHES =====

# SELinux blocks bind() on AF_NETLINK for non-root apps; udx-native needs a
# network interface watcher to build the DHT. The replacement file degrades
# gracefully to interfaces=[] (local IP falls back to 127.0.0.1), which keeps
# the daemon running; WAN discovery still works (HyperDHT learns the external
# IP from the UDP packet source).
_walkie_apply_netlink_patch() {
  loading "Applying netlink/SELinux patch to udx-native" _walkie_apply_netlink_patch_impl
}

_walkie_apply_netlink_patch_impl() {
  local root
  if [[ "$(_walkie_install_type)" == "global" ]]; then
    root="$PREFIX/lib/node_modules/walkie-sh"
  else
    root="$WALKIE_DATA_DIR"
  fi

  local patch_source="$WALKIE_PATCH_DIR/network-interfaces.js"
  if [[ ! -f "$patch_source" ]]; then
    log_error "Patch source not found: $patch_source"
    return 1
  fi

  local target
  for target in \
    "$root/node_modules/udx-native/lib/network-interfaces.js" \
    "$root/node_modules/walkie-sh/node_modules/udx-native/lib/network-interfaces.js"; do
    if [[ -f "$target" ]]; then
      cp -f "$patch_source" "$target" &>>"$LOG_FILE"
      return 0
    fi
  done

  log_error "udx-native not found in $root"
  return 1
}

# Generic AI-agent runner: walkie agent only accepts --cli claude|codex
# upstream; the patch relaxes validation and injects runGeneric so any agent
# CLI can be used. Only relevant for v1.5.0+ (has the agent command); skipped
# in legacy 1.4.0 mode where the anchors do not exist.
_walkie_apply_agents_patch() {
  loading "Applying generic agent runner patch" _walkie_apply_agents_patch_impl
}

_walkie_apply_agents_patch_impl() {
  [[ "${WALKIE_USE_140:-0}" == "1" ]] && return 0

  local patch="$WALKIE_PATCH_DIR/patch-agents.js"
  local js
  js=$(_walkie_resolve_js)
  if [[ ! -f "$patch" ]]; then
    log_error "Patch source not found: $patch"
    return 1
  fi
  if [[ -z "$js" ]]; then
    log_error "walkie.js not found. Run install again."
    return 1
  fi
  if ! "$(_walkie_node)" "$patch" "$js" &>>"$LOG_FILE"; then
    log_error "Generic agent runner patch failed"
    return 1
  fi
  return 0
}

# Strict solo-tag: --mention-only (respond only when @mentioned) and
# --respond-to <id> (respond only to a trusted sender), plus an anti-replay
# guard (START_TS) so a daemon restart never re-triggers old tasks. Must run
# AFTER patch-agents (anchors on the --skip-git-repo-check option inserted by
# that patch). Skipped in legacy 1.4.0 mode.
_walkie_apply_mention_patch() {
  loading "Applying strict solo-tag patch" _walkie_apply_mention_patch_impl
}

_walkie_apply_mention_patch_impl() {
  [[ "${WALKIE_USE_140:-0}" == "1" ]] && return 0

  local patch="$WALKIE_PATCH_DIR/patch-mention-only.js"
  local js
  js=$(_walkie_resolve_js)
  if [[ ! -f "$patch" ]]; then
    log_error "Patch source not found: $patch"
    return 1
  fi
  if [[ -z "$js" ]]; then
    log_error "walkie.js not found. Run install again."
    return 1
  fi
  if ! "$(_walkie_node)" "$patch" "$js" &>>"$LOG_FILE"; then
    log_error "Strict solo-tag patch failed"
    return 1
  fi
  return 0
}

# Channel member tracking: opt-in --track-members flag that keeps a roster of
# local members + remote peers, injects it into the agent prompt only when
# membership changed (delta-based), and persists it to ~/.walkie/roster-*.json
# so it survives restarts. Idempotent; must run after patch-agents and
# patch-mention-only (anchors on the options/filters they insert).
# Skipped in legacy 1.4.0 mode.
_walkie_apply_members_patch() {
  loading "Applying channel member tracking patch" _walkie_apply_members_patch_impl
}

_walkie_apply_members_patch_impl() {
  [[ "${WALKIE_USE_140:-0}" == "1" ]] && return 0

  local patch="$WALKIE_PATCH_DIR/patch-members.js"
  local js
  js=$(_walkie_resolve_js)
  if [[ ! -f "$patch" ]]; then
    log_error "Patch source not found: $patch"
    return 1
  fi
  if [[ -z "$js" ]]; then
    log_error "walkie.js not found. Run install again."
    return 1
  fi
  if ! "$(_walkie_node)" "$patch" "$js" &>>"$LOG_FILE"; then
    log_error "Channel member tracking patch failed"
    return 1
  fi
  rm -f "${js}.bak-members" &>>"$LOG_FILE"
  return 0
}

# ===== AGENT WRAPPERS =====
# Detect the AI agents installed and generate a launcher wrapper for each one
# in ~/.local/bin so walkie's generic runner can spawn them. This fixes the
# broken "#!/usr/bin/env node" shebang of bun-managed agents (gemini, qwen,
# kimi, mmx, openclaude, pi, supercode, openclaw) on Termux, where /usr/bin/env
# does not exist. Existing plain wrappers without our marker (e.g. core's own
# agy/vibe/opencode launchers) are left untouched.

_walkie_generate_wrappers() {
  loading "Generating agent wrappers" _walkie_generate_wrappers_impl
}

_walkie_generate_wrappers_impl() {
  local wrap_dir="$HOME/.local/bin"
  local wrap_marker="# walkie agent wrapper"

  # Package -> candidate binaries. First installed candidate wins.
  declare -A agent_bins
  agent_bins[antigravity]="agy"
  agent_bins[ampcode]="amp"
  agent_bins[claude-code]="claude"
  agent_bins[cline]="cline"
  agent_bins[codebuff]="codebuff"
  agent_bins[codex]="codex"
  agent_bins[command-code]="command-code"
  agent_bins[copilot-cli]="copilot copilot-cli"
  agent_bins[cursor]="cursor cursor-agent"
  agent_bins[droid-factory]="droid"
  agent_bins[freebuff]="freebuff"
  agent_bins[gemini-cli]="gemini"
  agent_bins[goose]="goose"
  agent_bins[hermes-agent]="hermes hermes-agent"
  agent_bins[keelcode]="keelcode"
  agent_bins[kilocode]="kilo kilocode"
  agent_bins[kimchi]="kimchi"
  agent_bins[kimi-code]="kimi kimi-code"
  agent_bins[mimocode]="mimo mimocode"
  agent_bins[minimax]="minimax mmx"
  agent_bins[mistral-vibe]="vibe"
  agent_bins[oh-my-pi]="omp"
  agent_bins[openclaw]="openclaw"
  agent_bins[openclaude]="openclaude"
  agent_bins[opencode]="opencode"
  agent_bins[pi]="pi"
  agent_bins[qoder]="qodercli"
  agent_bins[qwen-code]="qwen qwen-code"
  agent_bins[supercode]="supercode"

  # Manual (core launcher style) wrapper for these; universal for the rest.
  local manual_pkgs="codex claude"

  # Agent packages to scan. Non-agent complements (ctx7, engram, gentle-ai,
  # gga, cactus*, codegraph, hugging-face, openspec, ollama) are excluded.
  local agent_list="antigravity ampcode claude-code cline codebuff codex command-code copilot-cli cursor droid-factory freebuff gemini-cli goose hermes-agent keelcode kilocode kimchi kimi-code mimocode minimax mistral-vibe oh-my-pi openclaw openclaude opencode pi qoder qwen-code supercode"

  mkdir -p "$wrap_dir"

  # Remove stale wrappers from a previous install (identified by marker).
  local f
  for f in "$wrap_dir"/*; do
    [[ -f "$f" ]] || continue
    grep -q "$wrap_marker" "$f" 2>/dev/null && rm -f "$f"
  done

  # Manual wrapper (codex / claude): delegate to the real binary.
  write_manual_wrapper() {
    local name="$1" real="$2"
    # Keep an existing manual wrapper (e.g. the codex one) untouched.
    if [[ -e "$wrap_dir/$name" ]] && ! grep -q "$wrap_marker" "$wrap_dir/$name" 2>/dev/null; then
      log_info "Keeping existing manual wrapper $wrap_dir/$name"
      return
    fi
    rm -f "$wrap_dir/$name"
    cat > "$wrap_dir/$name" << 'WRAPEOF'
#!/data/data/com.termux/files/usr/bin/bash
# walkie agent wrapper: @NAME@
# Delegates to the real binary (fixes shebang issues on Termux).
exec "@REAL@" "$@"
WRAPEOF
    sed -i "s|@NAME@|${name}|g; s|@REAL@|${real}|g" "$wrap_dir/$name"
    chmod +x "$wrap_dir/$name"
  }

  # Universal wrapper: resolves a broken "#!/usr/bin/env" shebang at runtime.
  write_universal_wrapper() {
    local name="$1" real="$2"
    rm -f "$wrap_dir/$name"
    cat > "$wrap_dir/$name" << 'WRAPEOF'
#!/data/data/com.termux/files/usr/bin/bash
# walkie agent wrapper: @NAME@
REAL="@REAL@"
[[ -x "$REAL" ]] || { echo "walkie-wrapper: $REAL not found (agent removed?)" >&2; exit 127; }
[[ "$(head -c 2 "$REAL")" != '#!' ]] && exec "$REAL" "$@"
read -r first < "$REAL"
if [[ "$first" == '#!/usr/bin/env '* ]]; then
  prog=${first#*env }; prog=${prog%% *}
  [[ "$prog" == python* ]] && prog=python3
  command -v "$prog" >/dev/null 2>&1 && exec "$prog" "$REAL" "$@"
fi
exec "$REAL" "$@"
WRAPEOF
    sed -i "s|@NAME@|${name}|g; s|@REAL@|${real}|g" "$wrap_dir/$name"
    chmod +x "$wrap_dir/$name"
  }

  # Resolve the real executable of a candidate binary.
  # Returns: 0 + real path | 1 = not installed | 2 = existing manual wrapper.
  resolve_agent_real() {
    local cand="$1" bin real
    bin=$(command -v "$cand" 2>/dev/null) || return 1
    [[ -n "$bin" ]] || return 1
    # Existing plain wrapper in WRAP_DIR without our marker: leave it alone.
    if [[ -f "$bin" ]] && [[ "$(dirname "$bin")" == "$wrap_dir" ]] \
       && ! grep -q "$wrap_marker" "$bin" 2>/dev/null; then
      return 2
    fi
    real=$(readlink -f "$bin")
    # Unwrap our own previous wrapper to avoid an exec loop.
    if [[ -f "$bin" ]] && grep -q "$wrap_marker" "$bin" 2>/dev/null; then
      real=$(grep '^REAL="' "$bin" | head -1 | sed 's/^REAL="\(.*\)"$/\1/')
    fi
    [[ -n "$real" ]] && [[ -e "$real" ]] || return 1
    echo "$real"
    return 0
  }

  local pkg local_bins installed real cand rc r
  for pkg in $agent_list; do
    local_bins="${agent_bins[${pkg}]:-$pkg}"
    installed=""
    real=""
    for cand in $local_bins; do
      rc=0
      r=$(resolve_agent_real "$cand") || rc=$?
      if [[ $rc -eq 0 ]]; then
        installed="yes"; real="$r"; break
      elif [[ $rc -eq 2 ]]; then
        installed="manual"; break
      fi
    done
    [[ -z "$installed" ]] && continue
    if [[ "$installed" == "manual" ]]; then
      log_info "Manual wrapper for $pkg already present, skipping"
      continue
    fi
    local alias
    for alias in $local_bins; do
      if [[ " $manual_pkgs " == *" $alias "* ]]; then
        write_manual_wrapper "$alias" "$real"
      else
        write_universal_wrapper "$alias" "$real"
      fi
    done
    log_info "Wrappers generated for $pkg ($local_bins)"
  done

  return 0
}

# ===== LAUNCHER =====

_walkie_install_launcher() {
  loading "Installing walkie launcher" _walkie_install_launcher_impl
}

_walkie_install_launcher_impl() {
  if [[ ! -f "$WALKIE_LAUNCHER" ]]; then
    log_error "Launcher not found: $WALKIE_LAUNCHER"
    return 1
  fi
  if ! cp -f "$WALKIE_LAUNCHER" "$WALKIE_BIN" &>>"$LOG_FILE"; then
    log_error "Failed to install launcher to $WALKIE_BIN"
    return 1
  fi
  chmod +x "$WALKIE_BIN"
  return 0
}

# ===== VERIFICATION =====

_walkie_verify() {
  loading "Verifying walkie installation" _walkie_verify_impl
}

_walkie_verify_impl() {
  local js
  js=$(_walkie_resolve_js)
  if [[ -z "$js" ]]; then
    log_error "walkie.js not found. Run install again."
    return 1
  fi
  if timeout 20 "$(_walkie_node)" "$js" status &>>"$LOG_FILE"; then
    log_info "walkie installation finished. (mode: $(_walkie_install_type))"
    log_info "Run 'walkie' to execute it."
    return 0
  else
    log_warn "Daemon verification timed out (expected on first run). Run 'walkie status' to check."
    return 0
  fi
}

# ===== PUBLIC COMMANDS =====

install_walkie() {
  if command -v walkie &>/dev/null; then
    log_info "walkie is already installed"
    return 2
  fi

  separator
  box_large "Installing Walkie"
  separator
  echo

  log_info "Installing walkie..."
  mkdir -p "$(dirname "$LOG_FILE")" "$WALKIE_DATA_DIR"

  _walkie_dependencies || return 1
  _walkie_install_pkg || return 1
  _walkie_apply_netlink_patch || return 1
  _walkie_apply_agents_patch || return 1
  _walkie_apply_mention_patch || return 1
  _walkie_apply_members_patch || return 1
  _walkie_generate_wrappers || return 1
  _walkie_install_launcher || return 1
  _walkie_verify || return 1

  log_success "walkie installed"
  return 0
}

uninstall_walkie() {
  if ! command -v walkie &>/dev/null && [[ ! -d "$WALKIE_DATA_DIR" ]]; then
    log_info "walkie is not installed"
    return 2
  fi

  separator
  box_large "Uninstalling Walkie"
  separator
  echo

  confirm_remove_configs "Walkie" \
    "$WALKIE_DIR_CONFIG"

  log_info "Uninstalling walkie..."
  mkdir -p "$(dirname "$LOG_FILE")"

  # Remove agent wrappers generated by walkie (identified by marker).
  local wrap_marker="# walkie agent wrapper"
  local f
  if [[ -d "$HOME/.local/bin" ]]; then
    for f in "$HOME/.local/bin"/*; do
      [[ -f "$f" ]] || continue
      grep -q "$wrap_marker" "$f" 2>/dev/null && rm -f "$f"
    done
  fi

  rm -f "$WALKIE_BIN"
  rm -f "$PREFIX/lib/node_modules/walkie-sh/bin/walkie.js"
  rm -rf "$WALKIE_DATA_DIR"
  rm -rf "$PREFIX/lib/node_modules/walkie-sh"

  if [[ ! -f "$WALKIE_BIN" ]] && [[ ! -d "$WALKIE_DATA_DIR" ]]; then
    log_success "walkie uninstalled"
    return 0
  else
    log_error "Failed to uninstall walkie"
    return 1
  fi
}

_update_walkie() {
  mkdir -p "$(dirname "$LOG_FILE")"

  _walkie_dependencies || return 1
  _walkie_install_pkg || return 1
  _walkie_apply_netlink_patch || return 1
  _walkie_apply_agents_patch || return 1
  _walkie_apply_mention_patch || return 1
  _walkie_apply_members_patch || return 1
  _walkie_generate_wrappers || return 1
  _walkie_install_launcher || return 1
  _walkie_verify || return 1

  log_success "walkie updated"
  return 0
}

# Remote version must resolve the same git spec the installer uses
# (github:vikasprogrammer/walkie, package name `walkie-sh`). The GitHub
# repo has no releases/tags and the npm `walkie-sh` package is a frozen
# 1.4.0 artifact, so query the git spec via npm (npm >= 10 understands
# it) and fall back to the upstream package.json on the default branch.
# NOTE: `_walkie_remote_version` must be defined before it is used by
# the verb dispatcher at the bottom of this file.
WALKIE_PKG_JSON_URL="https://raw.githubusercontent.com/vikasprogrammer/walkie/master/package.json"

_walkie_remote_version() {
  local v
  v=$(npm view github:vikasprogrammer/walkie version 2>/dev/null | head -1)
  if [ -z "$v" ]; then
    v=$(_spin_capture "Checking Walkie upstream" bash -c \
      "curl -fsSL '$WALKIE_PKG_JSON_URL' 2>/dev/null | grep '\"version\"' | head -1 | sed 's/[^0-9.]//g'")
  fi
  echo "$v"
}

update_walkie() {
  _check_update_needed "Walkie" "$(_get_installed_version walkie)" "$(_walkie_remote_version)" _update_walkie
}

reinstall_walkie() {
  uninstall_walkie
  install_walkie
}

# ===== verb dispatcher (called by the Core engine) =====
if [[ "${1:-}" == "install" ]]; then install_walkie; fi
if [[ "${1:-}" == "uninstall" ]]; then uninstall_walkie; fi
if [[ "${1:-}" == "update" ]]; then update_walkie; fi
if [[ "${1:-}" == "reinstall" ]]; then reinstall_walkie; fi
if [[ "${1:-}" == "version-local" ]]; then _get_installed_version walkie; fi
if [[ "${1:-}" == "version-remote" ]]; then _walkie_remote_version; fi
