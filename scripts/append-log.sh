#!/bin/bash
# append-log.sh — Universal log appender (concurrent-safe via flock)
# Usage: append-log.sh <agent-id> <event> <summary> [duration]
# Appelé par tous les agents (Claude Code, OpenClaw, MemuBot, Runner)

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

mkdir -p "$LOG_DIR"

# flock: safe si même agent appelle en parallèle
(
  flock -x 200
  cat >> "$LOG_FILE" << EOF

## $TIME | $AGENT | $EVENT

**Session-ID**: $SESSION_ID
**Duration**: $DURATION
**Summary**: $SUMMARY

---
EOF
) 200>"$LOG_FILE.lock"

# Commit non-bloquant (debounced)
nohup bash "$REPO/scripts/commit-logs.sh" > /dev/null 2>&1 &
