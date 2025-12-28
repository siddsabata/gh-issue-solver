#!/usr/bin/env bash
# Initialize the workspace directory structure for issue solving
set -euo pipefail

WORKSPACE=".claude-github-issue-solver"

echo "Initializing workspace: $WORKSPACE"

mkdir -p "$WORKSPACE/issue"
mkdir -p "$WORKSPACE/repro/fixtures"
mkdir -p "$WORKSPACE/logs"
mkdir -p "$WORKSPACE/notes"

# Create .gitignore to keep artifacts uncommitted
cat > "$WORKSPACE/.gitignore" << 'EOF'
# Keep all issue solver artifacts uncommitted
*
!.gitignore
EOF

echo "Workspace initialized:"
echo "  $WORKSPACE/issue/      - Issue snapshots"
echo "  $WORKSPACE/repro/      - Reproduction scripts"
echo "  $WORKSPACE/logs/       - Execution logs"
echo "  $WORKSPACE/notes/      - Assessment notes"
echo
echo "All artifacts will remain uncommitted."
