# Issue Solver Playbook

## Workflow Overview

```
FETCH → REPRO (red) → ASSESS → FIX → VERIFY (green) → OUTPUT
                ↑                         │
                └─────── loop on fail ────┘
```

## Phase 1: Fetch Issue

```bash
gh issue view <num> --json title,body,comments,labels,state > .claude-github-issue-solver/issue/issue.json
gh issue view <num> > .claude-github-issue-solver/issue/issue.md
```

Extract from the issue:
- **Expected behavior**: What should happen
- **Actual behavior**: What happens instead
- **Repro steps**: Commands or code to trigger the bug
- **Environment**: Python version, OS, package versions
- **Acceptance condition**: How we know it's fixed

If any of these are missing or ambiguous, note them for clarification.

## Phase 2: Create Reproduction Harness

See [REPRO_GUIDE.md](REPRO_GUIDE.md) for detailed guidance.

**Key requirements:**
1. Script must be self-contained and runnable from repo root
2. Must exit non-zero on failure (bug present), zero on success (bug fixed)
3. Must print clear PASS/FAIL status
4. Must be deterministic (no flaky behavior)

Create the repro harness:
```bash
mkdir -p .claude-github-issue-solver/repro
# Write repro.sh based on issue analysis
```

## Phase 3: Run Repro (Expect Red)

```bash
bash .claude-github-issue-solver/scripts/run_repro.sh
```

Expected: Script fails (exit 1) confirming the bug exists.

If repro passes unexpectedly:
- Issue may already be fixed
- Environment mismatch
- Repro script doesn't capture the actual bug

If repro is flaky:
- Stabilize before proceeding
- Add retries, timeouts, or seed fixes

## Phase 4: Assess / Diagnose

Write assessment to `.claude-github-issue-solver/notes/assessment.md`:

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

**Guidelines:**
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
bash .claude-github-issue-solver/scripts/run_repro.sh

# Optional: run test suite if pytest detected
uv run pytest -q
```

**If verification fails:**
- Do NOT proceed to output
- Loop back to Phase 4 (Assess)
- Update assessment with new findings
- Apply revised fix
- Verify again

## Phase 7: Output Summary

Generate final output with:

1. **Repro command + result**: `bash .claude-github-issue-solver/repro/repro.sh` → PASS
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

**Repro Script:**
\`\`\`bash
[contents of repro.sh for maintainers to verify]
\`\`\`
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
.claude-github-issue-solver/
├── issue/
│   ├── issue.md          ✓ Human-readable snapshot
│   └── issue.json        ✓ Machine-readable snapshot
├── repro/
│   ├── repro.sh          ✓ Reproduction script
│   └── README.md         ✓ How to run repro
├── logs/
│   └── *.log             ✓ Execution logs
└── notes/
    └── assessment.md     ✓ Diagnosis notes
```
