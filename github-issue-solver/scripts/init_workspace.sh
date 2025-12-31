#!/usr/bin/env bash
# Initialize the workspace directory structure for issue solving
set -euo pipefail

# Find repo root (go up until we find .git or pyproject.toml)
REPO_ROOT="$(pwd)"
while [ "$REPO_ROOT" != "/" ]; do
    if [ -d "$REPO_ROOT/.git" ] || [ -f "$REPO_ROOT/pyproject.toml" ]; then
        break
    fi
    REPO_ROOT="$(dirname "$REPO_ROOT")"
done

WORKSPACE="$REPO_ROOT/.claude/gh-issue-solver"
ISSUES_DIR="$WORKSPACE/issues"

echo "Initializing workspace: $WORKSPACE"

mkdir -p "$ISSUES_DIR"

# Create .gitignore to keep artifacts uncommitted
cat > "$WORKSPACE/.gitignore" << 'EOF'
# Keep all issue solver artifacts uncommitted
*
!.gitignore
EOF

echo "Workspace initialized:"
echo "  $ISSUES_DIR/<issue_num>/issue/   - Issue snapshots"
echo "  $ISSUES_DIR/<issue_num>/repro/   - Reproduction scripts"
echo "  $ISSUES_DIR/<issue_num>/logs/    - Execution logs"
echo "  $ISSUES_DIR/<issue_num>/notes/   - Triage/assessment notes"
echo
echo "All artifacts will remain uncommitted."
