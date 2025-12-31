# Issue Solver Playbook

## Workflow Overview

```
FETCH → REPRO (red) → ASSESS → FIX → VERIFY (green) → OUTPUT
                ↑                         │
                └─────── loop on fail ────┘
```

## Phase 0: Check Project Guidelines

Before starting, look for existing agent guideline files:

```bash
ls -la claude.md CLAUDE.md agents.md AGENTS.md 2>/dev/null
```

If found:
- Read the file and follow project-specific conventions
- Note any testing, style, or workflow requirements

If not found:
- Proceed with skill defaults
- Create `claude.md` at the end with discovered project patterns

## Phase 1: Fetch Issue

```bash
bash <skill-path>/scripts/init_workspace.sh
bash <skill-path>/scripts/fetch_issue.sh <num>
```

Extract from the issue:
- **Expected behavior**: What should happen
- **Actual behavior**: What happens instead
- **Repro steps**: Commands or code to trigger the bug
- **Environment**: Python version, OS, package versions
- **Acceptance condition**: How we know it's fixed

If any of these are missing or ambiguous, note them for clarification.

## Phase 2: Triage (Actionable vs User Error/Upstream/Niche)

Before writing a repro, quickly assess whether the report is likely:
- A real bug in this repo vs **user error / misunderstanding**
- **Upstream/downstream** (belongs in a dependency or a consumer repo)
- A **niche/low-impact** edge case vs broadly affecting users
- Missing critical details (versions, platform, config, exact commands, full traceback)

Write `.claude/gh-issue-solver/issues/<num>/notes/triage.md` with:
- Classification: `bug` / `usage-question` / `feature-request` / `upstream` / `insufficient-info`
- Confidence + why
- Next action (proceed, ask for info, redirect upstream, propose close/doc update)

If it’s not actionable, stop early and output a maintainer-ready comment requesting the minimum missing info or pointing to the correct repo/docs.

## Phase 3: Create Reproduction Harness

See [REPRO_GUIDE.md](REPRO_GUIDE.md) for detailed guidance.

**Key requirements:**
1. Two files: `repro.py` (logic) + `repro.sh` (wrapper)
2. Must exit non-zero on failure (bug present), zero on success (bug fixed)
3. Must print clear PASS/FAIL status
4. Must be deterministic (no flaky behavior)

Create the repro harness:
```bash
mkdir -p .claude/gh-issue-solver/issues/<num>/repro
# Write repro.py and repro.sh based on issue analysis
```

## Phase 4: Run Repro (Expect Red)

```bash
bash <skill-path>/scripts/run_repro.sh <num>
```

Expected: Script fails (exit 1) confirming the bug exists.

If repro passes unexpectedly:
- Issue may already be fixed
- Environment mismatch
- Repro script doesn't capture the actual bug

If repro is flaky:
- Stabilize before proceeding
- Add retries, timeouts, or seed fixes

## Phase 5: Assess / Diagnose

Write assessment to `.claude/gh-issue-solver/issues/<num>/notes/assessment.md`:

```markdown
## Failure Signature
[Error message, traceback, unexpected output]

## Minimal Trigger
[Smallest code/config that triggers the bug]

## Hypotheses (ranked)
1. [Most likely] ...
2. [Possible] ...
3. [Less likely] ...

## Selected Root Cause
[Based on code analysis, which hypothesis is correct and why]
```

Investigation approach:
1. Read the stack trace / error output
2. Trace the code path from entry point
3. Identify where expected != actual
4. Find the root cause, not just symptoms

## Phase 5: Apply Fix

### Solution Ranking Criteria

When multiple fixes are possible, rank by:

1. **Least breaking** (highest priority)
   - Prefer fixes that don't touch shared code paths
   - Avoid changes that could affect unrelated features
   - Be gentle—surgical fixes over sweeping changes

2. **Shortest diff**
   - Fewer lines changed = lower risk of regressions
   - Single-line fix > multi-line fix
   - Local change > change + new helper function

3. **Strong typing**
   - Add type hints to touched code
   - Prefer `Optional[X]` over implicit `None`
   - Use typed containers (`list[str]` not `list`)

### Guidelines

- Minimal change - fix only what's broken
- No drive-by refactors
- No unrelated "improvements"
- Match existing code style
- Tests are optional (best effort)

Edit the source files in the repo to fix the bug.

## Phase 6: Verify

See [VERIFY_GUIDE.md](VERIFY_GUIDE.md) for detailed guidance.

```bash
# Run repro again - should pass now
bash <skill-path>/scripts/run_repro.sh <num>

# Optional: run test suite if pytest detected
uv run pytest -q
```

**If verification fails:**
- Do NOT proceed to output
- Loop back to Phase 5 (Assess)
- Update assessment with new findings
- Apply revised fix
- Verify again

## Phase 7: Output Summary

Generate final output with:

1. **Repro command + result**: `bash <skill-path>/scripts/run_repro.sh <num>` → PASS
2. **Root cause**: Brief explanation of what was wrong
3. **Changes made**: List of files and what was changed
4. **Verification**: Commands run and results

### GitHub Comment Template

Generate a paste-ready comment:

```markdown
## Investigation Summary

**Root Cause:** [1-2 sentence explanation]

**Changes:**
- `path/to/file.py`: [what was changed and why]

**Verification:**
- Repro script: PASS
- Test suite: [PASS/SKIP/N/A]

<details>
<summary>Repro Script (repro.py)</summary>

\`\`\`python
[contents of repro.py for maintainers to verify]
\`\`\`

</details>
```

## Loop Discipline

The fix-verify loop is the core value of this workflow:

1. Never skip verification
2. Never declare success on failed verification
3. Maximum 3 fix attempts before asking for help
4. Each iteration must have updated assessment notes

## Artifacts Checklist

Before completion, verify all artifacts exist:

```
.claude/gh-issue-solver/
├── issue/
│   ├── issue.md          ✓ Human-readable snapshot
│   └── issue.json        ✓ Machine-readable snapshot
├── repro/
│   ├── repro.py          ✓ Python reproduction logic
│   ├── repro.sh          ✓ Shell wrapper
│   └── README.md         ✓ How to run repro
├── logs/
│   └── *.log             ✓ Execution logs
└── notes/
    └── assessment.md     ✓ Diagnosis notes
```
