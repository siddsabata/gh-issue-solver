#!/usr/bin/env bash
# Fetch a GitHub issue and save to workspace
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: fetch_issue.sh <issue_number>"
    exit 1
fi

ISSUE_NUM="$1"
WORKSPACE=".claude/gh-issue-solver"
ISSUE_DIR="$WORKSPACE/issue"

mkdir -p "$ISSUE_DIR"

echo "Fetching issue #$ISSUE_NUM..."

# Fetch JSON format (for parsing)
if ! gh issue view "$ISSUE_NUM" --json number,title,body,comments,labels,state,author,createdAt,url > "$ISSUE_DIR/issue.json" 2>&1; then
    echo "ERROR: Failed to fetch issue #$ISSUE_NUM"
    echo "Check that:"
    echo "  - gh CLI is authenticated (gh auth status)"
    echo "  - You're in a GitHub repository"
    echo "  - Issue number is valid"
    exit 1
fi

# Fetch human-readable format
gh issue view "$ISSUE_NUM" > "$ISSUE_DIR/issue.md"

echo "Issue saved to:"
echo "  $ISSUE_DIR/issue.json (machine-readable)"
echo "  $ISSUE_DIR/issue.md (human-readable)"
