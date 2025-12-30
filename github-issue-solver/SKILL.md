---
name: github-issue-solver
description: Solve GitHub issues end-to-end using a disciplined reproduce-assess-fix-verify loop. Use when asked to "solve issue #X", "fix issue #X", "debug issue #X", or given a GitHub issue URL. Enforces deterministic reproduction, minimal fixes, and produces maintainer-ready summaries. Works with any Python + uv repository.
---

# GitHub Issue Solver

Automate a disciplined workflow for solving GitHub issues: fetch → reproduce → assess → fix → verify → output.

## Constraints

- **Language**: Python
- **Package manager**: uv
- **No commits**: All artifacts remain uncommitted in `.claude/gh-issue-solver/`
- **No PRs**: Output is a paste-ready comment, not a PR

## Workflow

```
FETCH → REPRO (red) → ASSESS → FIX → VERIFY → OUTPUT
                ↑                      │
                └────── loop ──────────┘
```

### 0. Check for Project Guidelines

Before starting, check for existing agent guideline files:
- `claude.md`, `CLAUDE.md`
- `agents.md`, `AGENTS.md`

If found, read and follow project-specific conventions. If none exist, create `claude.md` after completing the issue with discovered project context.

### 1. Initialize & Fetch

```bash
bash <skill-path>/scripts/init_workspace.sh
bash <skill-path>/scripts/fetch_issue.sh <issue_num>
```

Read `.claude/gh-issue-solver/issue/issue.md` and extract:
- Expected vs actual behavior
- Repro steps
- Environment details
- Acceptance condition

### 2. Create Reproduction

Create two files in `.claude/gh-issue-solver/repro/`:

**repro.py** - Python reproduction logic:
- Contains the actual test code
- Returns 0 if bug is fixed, 1 if bug is present
- Clear PASS/FAIL output

**repro.sh** - Thin shell wrapper:
- Sets up environment
- Calls `uv run python repro.py`

**IMPORTANT: Once created, do not edit the repro script.** The repro is the source of truth. If verification fails, fix the code—not the test. If the repro is fundamentally wrong, ask the user before modifying it.

See [references/REPRO_GUIDE.md](references/REPRO_GUIDE.md) for templates.

### 3. Run Repro (Expect Red)

```bash
bash <skill-path>/scripts/run_repro.sh
```

Must fail initially to confirm bug exists. If it passes, revisit repro logic.

### 4. Assess

Write `.claude/gh-issue-solver/notes/assessment.md`:
- Failure signature
- Minimal trigger conditions
- 2-4 ranked hypotheses
- Selected root cause with evidence

### 5. Fix

**Rank solutions by:**
1. **Least breaking** - Be gentle; avoid changes that could affect other code paths
2. **Shortest diff** - Fewer lines changed = less risk
3. **Strong typing** - Prefer typed solutions; add type hints if touching untyped code

Apply minimal patch to source files. No refactors. Match existing style.

### 6. Verify

```bash
bash <skill-path>/scripts/run_repro.sh
uv run pytest -q  # if pytest detected
```

**If verification fails**: Loop back to step 4. Max 3 attempts before asking user.

See [references/VERIFY_GUIDE.md](references/VERIFY_GUIDE.md) for details.

### 7. Output

Produce:
1. Root cause explanation
2. Files changed + intent
3. Verification results
4. Paste-ready GitHub comment

## GitHub Comment Template

```markdown
## Investigation Summary

**Root Cause:** [1-2 sentences]

**Changes:**
- `path/to/file.py`: [what and why]

**Verification:**
- Repro: PASS
- Tests: [PASS/SKIP/N/A]

<details>
<summary>Repro Script</summary>

\`\`\`python
[contents of repro.py]
\`\`\`

</details>
```

## Error Handling

- **Missing repro info**: After 2 failed attempts, ask user for specific details
- **gh auth failure**: Surface error, do not workaround
- **Flaky repro**: Stabilize before proceeding to fix

## Detailed Guides

- [PLAYBOOK.md](references/PLAYBOOK.md) - Full workflow with examples
- [REPRO_GUIDE.md](references/REPRO_GUIDE.md) - Reproduction harness patterns
- [VERIFY_GUIDE.md](references/VERIFY_GUIDE.md) - Verification procedures
