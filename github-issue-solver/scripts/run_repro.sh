#!/usr/bin/env bash
# Wrapper script to run reproduction with logging
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Find repo root (go up until we find .git or pyproject.toml)
REPO_ROOT="$(pwd)"
while [ "$REPO_ROOT" != "/" ]; do
    if [ -d "$REPO_ROOT/.git" ] || [ -f "$REPO_ROOT/pyproject.toml" ]; then
        break
    fi
    REPO_ROOT="$(dirname "$REPO_ROOT")"
done

WORKSPACE="$REPO_ROOT/.claude/gh-issue-solver"
REPRO_SCRIPT="$WORKSPACE/repro/repro.sh"
LOG_DIR="$WORKSPACE/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/repro_$TIMESTAMP.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

if [ ! -f "$REPRO_SCRIPT" ]; then
    echo "ERROR: Repro script not found at $REPRO_SCRIPT"
    echo "Create the repro script first."
    exit 2
fi

echo "=== Running Reproduction ===" | tee "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"
echo "Script: $REPRO_SCRIPT" | tee -a "$LOG_FILE"
echo "Log: $LOG_FILE" | tee -a "$LOG_FILE"
echo "============================" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# Run repro and capture output
cd "$REPO_ROOT"
bash "$REPRO_SCRIPT" 2>&1 | tee -a "$LOG_FILE"
EXIT_CODE=${PIPESTATUS[0]}

echo | tee -a "$LOG_FILE"
echo "=== Result ===" | tee -a "$LOG_FILE"
echo "Exit code: $EXIT_CODE" | tee -a "$LOG_FILE"
if [ $EXIT_CODE -eq 0 ]; then
    echo "Status: PASS" | tee -a "$LOG_FILE"
else
    echo "Status: FAIL" | tee -a "$LOG_FILE"
fi
echo "==============" | tee -a "$LOG_FILE"

exit $EXIT_CODE
