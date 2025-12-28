# github-issue-solver

A Claude Code skill that solves GitHub issues using a disciplined reproduce → assess → fix → verify loop.

## Requirements

- Claude Code
- `gh` CLI (authenticated)
- Python + `uv`
- Local clone of adk-python

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
Fix issue https://github.com/google/adk-python/issues/1234
```

## What It Does

1. Fetches the issue via `gh issue view`
2. Creates a reproduction script that fails (confirms bug exists)
3. Diagnoses the root cause
4. Applies a minimal fix
5. Verifies the fix (repro passes)
6. Outputs a paste-ready GitHub comment

All artifacts are stored in `.claude-github-issue-solver/` and remain uncommitted.

## Output

You get:
- Root cause explanation
- List of changed files
- Verification results
- A GitHub comment ready to paste
