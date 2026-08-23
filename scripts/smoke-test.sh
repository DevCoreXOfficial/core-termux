#!/usr/bin/env bash

# Core - pre-release smoke tests.
# Run before pushing: bash scripts/smoke-test.sh
# Uses a sandboxed HOME (via XDG overrides) so it never touches a real install.

set -u

PASS=0
FAIL=0

ok() { echo "  ✔ $1"; PASS=$((PASS + 1)); }
bad() { echo "  ✖ $1"; FAIL=$((FAIL + 1)); }

check() {
  # check <description> <command...>
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    ok "$desc"
  else
    bad "$desc"
  fi
}

echo
echo "── Core smoke tests ──"
echo

# 1. Shell syntax across every script.
SYNTAX_FAIL=0
while IFS= read -r f; do
  bash -n "$f" 2>/dev/null || {
    echo "  ✖ syntax: $f"
    SYNTAX_FAIL=1
  }
done < <(find "$(dirname "$0")/../core" -name "*.sh" -type f; echo "$(dirname "$0")/../install.sh")
[[ $SYNTAX_FAIL -eq 0 ]] && ok "bash -n on all shell scripts" || bad "shell syntax errors above"

# 2. Manifests are valid JSON with required fields.
MANIFESTS_BAD=0
while IFS= read -r m; do
  jq -e '.name and .platforms' "$m" >/dev/null 2>&1 || {
    echo "  ✖ manifest: $m"
    MANIFESTS_BAD=1
  }
done < <(find "$(dirname "$0")/../core/tools" -name "manifest.json")
[[ $MANIFESTS_BAD -eq 0 ]] && ok "all manifests valid" || bad "invalid manifests above"

# 3. Every tool has termux.sh + docs/en.md.
MISSING=0
while IFS= read -r d; do
  [[ -f "$d/install/termux.sh" ]] || {
    echo "  ✖ missing termux.sh: $d"
    MISSING=1
  }
  [[ -f "$d/docs/en.md" ]] || {
    echo "  ✖ missing docs/en.md: $d"
    MISSING=1
  }
done < <(find "$(dirname "$0")/../core/tools" -name manifest.json -exec dirname {} \;)
[[ $MISSING -eq 0 ]] && ok "every tool has termux.sh + docs" || bad "missing files above"

# 4. CLI behaviors inside an isolated sandbox.
SANDBOX="$(mktemp -d "${TMPDIR:-${HOME}/.cache}/core-smoke.XXXXXX")"
export XDG_CACHE_HOME="$SANDBOX/cache"
export XDG_DATA_HOME="$SANDBOX/data"
export XDG_CONFIG_HOME="$SANDBOX/config"
CORE="$(cd "$(dirname "$0")/../core" && pwd)"

check "--version prints 5.x" bash "$CORE/bin/core" --version
check "help renders" bash "$CORE/bin/core"

OUT=$(bash "$CORE/bin/core" search sql 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
[[ "$OUT" == *"sqlite"* ]] && ok "search filter works" || bad "search filter output"

OUT=$(bash "$CORE/bin/core" search 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
[[ "$OUT" == *"postgresql"* && "$OUT" == *"opencode"* ]] && ok "search shows all tools" || bad "search all output"

OUT=$(bash "$CORE/bin/core" list 2>&1)
[[ "$OUT" == *"Command not found"* || "$OUT" != *"sqlite"* ]] && ok "list removed in favor of search" || bad "list still present"

# Header assertions are renderer-independent (glow/bat/cat all print them).
OUT=$(bash "$CORE/bin/core" show opencode 2>&1)
echo "$OUT" | grep -q "OpenCode (opencode)" && ok "show renders doc" || bad "show output"
grep -q "Package Information" "$CORE/tools/opencode/docs/en.md" &&
  ok "doc structure present on disk" || bad "doc structure missing"

OUT=$(bash "$CORE/bin/core" about opencode 2>&1)
echo "$OUT" | grep -q "OpenCode (opencode)" && ok "about alias works" || bad "about output"

OUT=$(bash "$CORE/bin/core" install definitely-not-a-tool 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
[[ "$OUT" == *"Unknown"* ]] && ok "unknown tool rejected" || bad "unknown tool handling"

rm -rf "$SANDBOX"

echo
echo "── $PASS passed, $FAIL failed ──"
echo
exit $((FAIL > 0))
