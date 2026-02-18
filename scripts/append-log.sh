#!/bin/bash
# append-log.sh — macOS-compatible (mkdir lock, pas flock)
REPO="${HOME}/Desktop/session_david"
AGENT="${1:-unknown}"
EVENT="${2:-EVENT}"
SUMMARY="${3:-No summary}"
DURATION="${4:-unknown}"

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
SESSION_ID="${AGENT}-$(date +%Y%m%d%H%M%S)"
LOG_DIR="$REPO/docs/agents/$AGENT"
LOG_FILE="$LOG_DIR/$DATE.md"
LOCKDIR="$LOG_FILE.d"

mkdir -p "$LOG_DIR"

# mkdir est atomique sur macOS — lock simple et fiable
TRIES=0
until mkdir "$LOCKDIR" 2>/dev/null; do
  sleep 0.1
  TRIES=$((TRIES+1))
  [ $TRIES -gt 30 ] && break
done
trap "rmdir '$LOCKDIR' 2>/dev/null" EXIT

printf "\n## %s | %s | %s\n\n**Session-ID**: %s\n**Duration**: %s\n**Summary**: %s\n\n---\n" \
  "$TIME" "$AGENT" "$EVENT" "$SESSION_ID" "$DURATION" "$SUMMARY" >> "$LOG_FILE"

rmdir "$LOCKDIR" 2>/dev/null || true
trap - EXIT

# Commit non-bloquant
nohup bash "$REPO/scripts/commit-logs.sh" > /dev/null 2>&1 &
