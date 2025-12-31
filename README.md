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
3. Triages whether it’s actionable vs user error/upstream/niche
4. Creates a reproduction script (`repro.py` + `repro.sh`)
5. Diagnoses the root cause
6. Applies a minimal fix
7. Verifies the fix (repro passes)
8. Outputs a paste-ready GitHub comment

All artifacts are stored in `.claude/gh-issue-solver/issues/<issue_num>/` and remain uncommitted.

## Output

You get:
- Root cause explanation
- List of changed files
- Verification results
- A GitHub comment ready to paste
