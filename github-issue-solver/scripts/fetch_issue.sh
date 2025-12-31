#!/usr/bin/env bash
# Fetch a GitHub issue and save to workspace
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: fetch_issue.sh <issue_number>"
    exit 1
fi

ISSUE_NUM="${1#\#}"

# Find repo root (go up until we find .git or pyproject.toml)
REPO_ROOT="$(pwd)"
while [ "$REPO_ROOT" != "/" ]; do
    if [ -d "$REPO_ROOT/.git" ] || [ -f "$REPO_ROOT/pyproject.toml" ]; then
        break
    fi
    REPO_ROOT="$(dirname "$REPO_ROOT")"
done

WORKSPACE="$REPO_ROOT/.claude/gh-issue-solver"
ACTIVE_ISSUE_FILE="$WORKSPACE/ACTIVE_ISSUE"
ISSUE_ROOT="$WORKSPACE/issues/$ISSUE_NUM"
ISSUE_DIR="$ISSUE_ROOT/issue"

# Ensure workspace exists even if init_workspace.sh wasn't run
mkdir -p "$WORKSPACE/issues"
if [ ! -f "$WORKSPACE/.gitignore" ]; then
    cat > "$WORKSPACE/.gitignore" << 'EOF'
# Keep all issue solver artifacts uncommitted
*
!.gitignore
EOF
fi

mkdir -p "$ISSUE_DIR" "$ISSUE_ROOT/repro/fixtures" "$ISSUE_ROOT/logs" "$ISSUE_ROOT/notes"

echo "Fetching issue #$ISSUE_NUM..."

# Fetch JSON format (for parsing)
cd "$REPO_ROOT"
if ! gh issue view "$ISSUE_NUM" --json number,title,body,comments,labels,state,author,createdAt,url > "$ISSUE_DIR/issue.json" 2> "$ISSUE_DIR/gh_error.log"; then
    echo "ERROR: Failed to fetch issue #$ISSUE_NUM"
    echo "Check that:"
    echo "  - gh CLI is authenticated (gh auth status)"
    echo "  - You're in a GitHub repository"
    echo "  - Issue number is valid"
    exit 1
fi

# Fetch human-readable format
gh issue view "$ISSUE_NUM" > "$ISSUE_DIR/issue.md"

# Track the most recently fetched issue for convenience
echo "$ISSUE_NUM" > "$ACTIVE_ISSUE_FILE"

echo "Issue saved to:"
echo "  $ISSUE_DIR/issue.json (machine-readable)"
echo "  $ISSUE_DIR/issue.md (human-readable)"
echo "Active issue set to: $ISSUE_NUM"
