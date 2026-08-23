#!/usr/bin/env bash

# Core - publish the current working tree to the v5.0.0-beta branch.
# Usage: bash scripts/release-beta.sh

set -euo pipefail
cd "$(dirname "$0")/.."

BRANCH="v5.0.0-beta"
ASSUME_YES="${1:-}"

# 1. Never ship broken code.
if ! bash scripts/smoke-test.sh; then
  echo
  echo "Smoke tests failed — aborting."
  exit 1
fi

# 2. Show what will be committed.
echo
echo "Pending changes:"
git status --short | head -15 || true
echo "... ($(git status --short | wc -l) files total)"

# 3. Confirm.
if [[ "$ASSUME_YES" != "--yes" ]]; then
  printf "\nCommit everything and push to %s? [y/N] " "origin/$BRANCH"
  read -r ANSWER
  [[ "$ANSWER" == y* ]] || {
    echo "Aborted."
    exit 1
  }
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$CURRENT_BRANCH" != "$BRANCH" ]]; then
  # Work on the beta branch so main never receives commits directly.
  git checkout -B "$BRANCH"
fi

git add -A
git commit -m "${COMMIT_MSG:-chore(beta): snapshot}" ||
  echo "Nothing to commit."

# 4. Push the beta branch (main stays untouched).
git push -u origin "$BRANCH"

if [[ -n "$CURRENT_BRANCH" && "$CURRENT_BRANCH" != "$BRANCH" ]] && git show-ref --verify --quiet "refs/heads/$CURRENT_BRANCH"; then
  git checkout "$CURRENT_BRANCH"
fi

echo
ORIGIN_URL="$(git remote get-url origin | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
echo "✔ Beta published."
echo "  main        : untouched"
echo "  Testers run : curl -fsSL https://raw.githubusercontent.com/${ORIGIN_URL}/${BRANCH}/install.sh | CORE_BRANCH=${BRANCH} bash"
