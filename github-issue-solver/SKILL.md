---
name: github-issue-solver
description: Solve GitHub issues end-to-end using a disciplined reproduce-assess-fix-verify loop. Use when asked to "solve issue X", "fix issue X", or given a GitHub issue URL
---

# GitHub Issue Solver

Automate a disciplined workflow for solving GitHub issues: fetch → reproduce → assess → fix → verify → output.

## Constraints

- **Language**: Python
- **Package manager**: uv
- **No commits**: All artifacts remain uncommitted in `.claude/gh-issue-solver/`
- **No PRs**: Output is a paste-ready comment, not a PR
- **Per-issue workspace**: Store artifacts under `.claude/gh-issue-solver/issues/<issue_num>/` to avoid overwrites

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

Read `.claude/gh-issue-solver/issues/<issue_num>/issue/issue.md` and extract:
- Expected vs actual behavior
- Repro steps
- Environment details
- Reporter-proposed fix/workaround (if any)
- Acceptance condition

### 1b. Suggested Fixes Are Hypotheses

If the issue includes a suggested fix, workaround, or suspected cause:
- Treat it as a **hypothesis**, not a requirement
- Try to validate it against the repro and evidence
- Still generate and rank other plausible hypotheses before choosing a fix

### 2. Triage (Is This a Real/Actionable Issue?)

Before investing in a repro/fix, sanity-check whether the report is likely:
- A real bug in this repo vs **user error / misuse**
- **Upstream/downstream** (belongs in a dependency or consumer repo)
- **Niche/low-impact** vs broadly affecting users
- Missing critical info (versions, platform, config, exact commands, full traceback)

Write `.claude/gh-issue-solver/issues/<issue_num>/notes/triage.md` with:
- Classification: `bug` / `usage-question` / `feature-request` / `upstream` / `insufficient-info`
- Confidence + why (1-2 bullets)
- Next action: proceed to repro, ask for info, or propose a maintainer reply/close rationale

If it’s likely user error, upstream, or insufficient info, **stop early** and output a paste-ready GitHub comment that:
- Explains what seems off (without blaming the reporter)
- Requests the minimum missing details, or points to the correct repo/docs
- States what would make this actionable (a minimal repro, exact versions, etc.)

### 3. Create Reproduction

Create two files in `.claude/gh-issue-solver/issues/<issue_num>/repro/`:

**repro.py** - Python reproduction logic:
- Contains the actual test code
- Returns 0 if bug is fixed, 1 if bug is present
- Clear PASS/FAIL output

**repro.sh** - Thin shell wrapper:
- Sets up environment
- Calls `uv run python repro.py`

**IMPORTANT: Once created, do not edit the repro script.** The repro is the source of truth. If verification fails, fix the code—not the test. If the repro is fundamentally wrong, ask the user before modifying it.

See [references/REPRO_GUIDE.md](references/REPRO_GUIDE.md) for templates.

### 4. Run Repro (Expect Red)

```bash
bash <skill-path>/scripts/run_repro.sh <issue_num>  # issue_num optional if already fetched
```

Must fail initially to confirm bug exists. If it passes, revisit repro logic.

### 5. Assess

Write `.claude/gh-issue-solver/issues/<issue_num>/notes/assessment.md`:
- Failure signature
- Minimal trigger conditions
- 2-4 ranked hypotheses (include the reporter’s suggestion if present)
- Selected root cause with evidence

### 6. Fix

**Rank solutions by:**
1. **Least breaking** - Be gentle; avoid changes that could affect other code paths
2. **Shortest diff** - Fewer lines changed = less risk
3. **Strong typing** - Prefer typed solutions; add type hints if touching untyped code

Apply minimal patch to source files. No refactors. Match existing style.

### 7. Verify

```bash
bash <skill-path>/scripts/run_repro.sh <issue_num>  # issue_num optional if already fetched
uv run pytest -q  # if pytest detected
```

**If verification fails**: Loop back to step 5. Max 3 attempts before asking user.

See [references/VERIFY_GUIDE.md](references/VERIFY_GUIDE.md) for details.

### 8. Output

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
