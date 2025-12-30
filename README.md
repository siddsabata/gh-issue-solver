# github-issue-solver

A Claude Code skill that solves GitHub issues using a disciplined reproduce → assess → fix → verify loop.

## Requirements

- Claude Code
- `gh` CLI (authenticated)
- Python + `uv`

## Install

```bash
claude install-skill github-issue-solver.skill
```

Or add the `github-issue-solver/` directory to your Claude Code skills path.

## Usage

In Claude Code, say:

```
Solve issue #1234
```

Or:

```
Fix issue https://github.com/owner/repo/issues/1234
```

## What It Does

1. Checks for project guidelines (`claude.md`, `agents.md`)
2. Fetches the issue via `gh issue view`
3. Creates a reproduction script (`repro.py` + `repro.sh`)
4. Diagnoses the root cause
5. Applies a minimal fix
6. Verifies the fix (repro passes)
7. Outputs a paste-ready GitHub comment

All artifacts are stored in `.claude/gh-issue-solver/` and remain uncommitted.

## Output

You get:
- Root cause explanation
- List of changed files
- Verification results
- A GitHub comment ready to paste
