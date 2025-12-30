# Verification Guide

## Verification Checklist

Before declaring a fix complete:

1. **Repro script passes** (required)
2. **Test suite passes** (if present)
3. **No regressions introduced** (best effort)

## Running Verification

### Step 1: Repro Script

```bash
bash .claude/gh-issue-solver/repro/repro.sh
```

Expected output:
```
=== PASS: Bug appears to be fixed ===
```

**If FAIL**: Loop back to assessment phase. Do not proceed.

### Step 2: Test Suite (if detected)

Check for pytest:
```bash
[ -f "pyproject.toml" ] && grep -q "pytest" pyproject.toml && echo "pytest detected"
```

Run tests:
```bash
uv run pytest -q
```

**Acceptable outcomes:**
- All tests pass
- Pre-existing failures unrelated to the fix
- No test suite exists (skip this step)

**Not acceptable:**
- New test failures caused by the fix
- Test suite cannot run due to fix

### Step 3: Quick Sanity Checks

```bash
# Syntax check
uv run python3 -m py_compile <modified_files>

# Import check
uv run python3 -c "import <package>"

# Type check if mypy configured
uv run mypy <modified_files> --ignore-missing-imports
```

## Verification Failures

### Repro Still Fails

The fix is incorrect or incomplete.

1. Re-read the assessment
2. Check if fix addresses root cause
3. Look for off-by-one, edge cases, etc.
4. Update fix and verify again

### Test Suite Fails

Determine if failure is related:

**Related failure** (fix broke something):
- Revise the fix approach
- May need different solution
- Update assessment with new constraint

**Unrelated failure** (pre-existing):
- Note in output summary
- Proceed with verification

### Flaky Results

If repro sometimes passes, sometimes fails:

1. Identify source of non-determinism
2. Fix repro script first
3. Do not proceed until repro is stable

## Loop Limits

After 3 failed verification attempts:

1. Document what was tried
2. Summarize blockers
3. Ask user for guidance
4. Do not continue blindly

## Verification Output

Record in logs:

```
.claude/gh-issue-solver/logs/verify_<timestamp>.log
```

Log contents:
```
=== Verification Run: 2024-01-15 10:30:00 ===
Repro: PASS
Pytest: PASS (42 passed, 2 skipped)
Syntax: OK
==========================================
```

## Success Criteria

Verification is complete when:

- [ ] repro.py exits 0
- [ ] No new test failures
- [ ] Modified files have valid syntax
- [ ] Package still imports correctly

Only then proceed to output phase.
