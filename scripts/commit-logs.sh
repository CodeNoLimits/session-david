#!/bin/bash
# commit-logs.sh — Debounced git commit (evite hammer GitHub API)
REPO="${HOME}/Desktop/session_david"
LOCK="/tmp/session-david-commit.lock"

[ -f "$LOCK" ] && exit 0
touch "$LOCK"
trap "rm -f $LOCK" EXIT

cd "$REPO" || exit 1
git add docs/agents/ 2>/dev/null
if ! git diff --staged --quiet 2>/dev/null; then
  git commit -m "chore: agent log $(date +%Y-%m-%dT%H:%M:%S)"
  git push origin main --quiet 2>&1 || true
fi
