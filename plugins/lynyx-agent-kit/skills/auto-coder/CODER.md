# Coding Phase Instructions

This document provides detailed instructions for the Coding Agent (Sessions 2+) of the auto-coder workflow.

## Prerequisites

Before running the coding phase:

1. **Initialization must be complete** - `.auto-coder/feature_list.json` must exist
2. **Git repository initialized** - Project must have `.git` directory

If prerequisites aren't met:

> ERROR: Auto-coder not initialized.
>
> Run initialization first:
> ```
> /lynyx-agent-kit:auto-coder init SPEC.txt
> ```

## Sub-Agent Architecture

To optimize context window usage, the coding phase uses two specialized sub-agents:

1. **Task Selector Agent** (`agents/task-selector.md`): Reads `feature_list.json` and reports the next task in a compact format
2. **Task Implementer Agent** (`agents/task-implementer.md`): Implements the selected task and updates tracking files

This approach prevents the main agent's context window from being filled with the full feature list.

## Coding Workflow (3 Steps)

### Step 1: Spawn Task Selector Agent

Spawn a sub-agent using the instructions from `agents/task-selector.md`.

The sub-agent will:
1. Read `.auto-coder/feature_list.json`
2. Identify the next incomplete feature
3. Report essential task information in a compact format

**Expected output format:**

```
TASK_SELECTOR_REPORT
---
project_name: {PROJECT_NAME}
project_prefix: {PREFIX}
progress: {COMPLETED}/{TOTAL}
next_task:
  id: {TASK_ID}
  description: {DESCRIPTION}
  category: {CATEGORY}
  priority: {PRIORITY}
  steps:
    - {STEP 1}
    - {STEP 2}
    ...
high_priority_passing:
  - {TASK_ID_1}
  - {TASK_ID_2}
  ...
---
END_REPORT
```

**Handle special cases:**
- If `status: COMPLETE`, all features are done - display project completion message
- If `status: NOT_INITIALIZED`, show initialization error
- If `status: ERROR`, display the error and abort

### Step 2: Spawn Task Implementer Agent

Once you have the task details from Step 1, spawn a sub-agent using the instructions from `agents/task-implementer.md`.

Pass the task information to the sub-agent in this format:

```
IMPLEMENT_TASK
---
project_name: {PROJECT_NAME}
project_prefix: {PREFIX}
task:
  id: {TASK_ID}
  description: {DESCRIPTION}
  category: {CATEGORY}
  priority: {PRIORITY}
  steps:
    - {STEP 1}
    - {STEP 2}
    ...
high_priority_passing:
  - {TASK_ID_1}
  - {TASK_ID_2}
  ...
---
```

The sub-agent will:
1. Run regression tests on high-priority passing features
2. Implement the feature
3. Verify all test steps pass
4. Update `feature_list.json`
5. Create git commit
6. Update `progress.md`

### Step 3: Handle Implementer Response

Parse the response from the Task Implementer agent and take appropriate action:

**On SUCCESS:**
Display the session completion message with progress and next steps.

**On REGRESSION_FOUND:**
Report the regression and suggest fixing it before proceeding.

**On TESTS_FAILED:**
Report which tests failed and suggest debugging.

**On ERROR:**
Display the error message and abort.

## Legacy Workflow Reference

The detailed step-by-step workflow (for reference or manual execution) follows below. These steps were previously executed directly by the main agent, but are now handled by the Task Implementer sub-agent.

### Legacy Step 1: Regression Check (HIGH PRIORITY ONLY)

**MANDATORY:** Before starting new work, verify existing functionality still works.

1. **Identify HIGH priority features marked as passing:**
   ```javascript
   // Filter: priority === "high" && passes === true
   ```

2. **Run ALL tests for these features:**
   - Execute the test steps for each passing high-priority feature
   - This may involve running test suites, manual verification, or both

3. **If ANY regression found:**
   - **STOP** - Do not proceed to new features
   - Mark the regressed feature as `passes: false` in feature_list.json
   - Fix the regression first
   - Re-run regression tests
   - Only proceed when all high-priority tests pass again

**Why HIGH priority only:**
- Focuses regression testing on critical functionality
- Reduces overhead while catching important breakages
- Medium/low features are tested when their turns come

### Legacy Step 2: Feature Selection

Select the next feature to implement:

1. Find the first feature where `passes: false`
   - Features are pre-ordered by critical path (priority + dependencies)
   - Simply take the first incomplete one

2. Read the feature details:
   - `task_id` - For session naming
   - `description` - What to implement
   - `steps` - How to verify completion
   - `category` - functional/style/non-functional

3. Rename the session:
   ```
   /rename auto-coder: {PROJECT_NAME} | {TASK_ID}
   ```

### Legacy Step 3: Implementation

Implement the feature according to its description and test steps.

**Guidelines:**

1. **Follow project conventions:**
   - Match existing code style
   - Use established patterns
   - Maintain consistent naming

2. **Implement incrementally:**
   - Start with the simplest working version
   - Add complexity as needed
   - Test frequently during development

3. **Consider the test steps:**
   - Each step should pass after implementation
   - Steps guide what needs to be built
   - Cover both happy path and edge cases

4. **Security and quality:**
   - Validate inputs appropriately
   - Handle errors gracefully
   - Avoid introducing vulnerabilities

### Legacy Step 4: Test Verification

**ALL tests for this feature must pass before marking complete.**

Execute each test step in order:

```markdown
Feature: MWA-001 - User authentication with email/password

[ ] Step 1: Navigate to /login page
[ ] Step 2: Verify email and password input fields are present
[ ] Step 3: Submit form with invalid credentials
[ ] Step 4: Verify error message is displayed
[ ] Step 5: Submit form with valid credentials
[ ] Step 6: Verify redirect to /dashboard
```

**Verification methods:**
- Run automated test suites (`npm test`, `pytest`, etc.)
- Manual browser/UI testing where applicable
- API endpoint testing with curl/httpie
- Check console for errors

**Requirements to pass:**
- Every test step must succeed
- Zero console errors related to this feature
- Behavior matches specification exactly
- No regressions in existing functionality

**If any test fails:**
- Do NOT mark feature as passing
- Debug and fix the issue
- Re-run ALL tests for this feature
- Repeat until all pass

### Legacy Step 5: Update Feature List

**Only after ALL tests pass**, update `feature_list.json`:

```json
{
  "id": 1,
  "task_id": "MWA-001",
  "passes": true,
  "completed_at": "2026-01-07T14:30:00Z",
  "commit_hash": null  // Will be set after commit
}
```

**Update the summary section:**
```json
"summary": {
  "total": 50,
  "completed": 1,  // Increment
  "remaining": 49, // Decrement
  "by_priority": {
    "high": { "total": 15, "completed": 1 }  // Update appropriate priority
  }
}
```

**Update `last_updated`:**
```json
"project": {
  "last_updated": "2026-01-07T14:30:00Z"
}
```

### Legacy Step 6: Git Commit

Create a descriptive commit for the completed feature:

```bash
git add -A

git commit -m "$(cat <<'EOF'
feat(auto-coder): {TASK_ID} - {DESCRIPTION}

Implements:
- {Specific change 1}
- {Specific change 2}
- {Specific change 3}

Tests: {N}/{N} passing
EOF
)"
```

**Update feature_list.json with commit hash:**

```bash
# Get the commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)
```

Update the feature's `commit_hash` field in feature_list.json.

**Commit the updated feature_list.json:**

```bash
git add .auto-coder/feature_list.json
git commit --amend --no-edit
```

### Legacy Step 7: Update Progress Log

Append to `.auto-coder/progress.md`:

```markdown
## Session {N}: {TASK_ID}
**Date:** {TIMESTAMP}

### Completed
- **{TASK_ID}:** {DESCRIPTION}
  - Category: {CATEGORY}
  - Priority: {PRIORITY}
  - Tests: {PASSED}/{TOTAL} passing
  - Commit: {COMMIT_HASH}

### Progress
- Completed: {COMPLETED}/{TOTAL} ({PERCENTAGE}%)
- Remaining: {REMAINING}

### Next Feature
- **{NEXT_TASK_ID}:** {NEXT_DESCRIPTION}

---
```

### Legacy Step 8: Session Completion

Output session completion message:

```
═══════════════════════════════════════════════════════════════════════════════
                           SESSION COMPLETE
═══════════════════════════════════════════════════════════════════════════════

Completed: {TASK_ID} - {DESCRIPTION}
Commit: {COMMIT_HASH}

Progress: {COMPLETED}/{TOTAL} features ({PERCENTAGE}%)
  High:   {HIGH_COMPLETED}/{HIGH_TOTAL}
  Medium: {MEDIUM_COMPLETED}/{MEDIUM_TOTAL}
  Low:    {LOW_COMPLETED}/{LOW_TOTAL}

═══════════════════════════════════════════════════════════════════════════════
                              NEXT STEPS
═══════════════════════════════════════════════════════════════════════════════

Next feature: {NEXT_TASK_ID} - {NEXT_DESCRIPTION}

To continue in a NEW session:

  claude -p "/lynyx-agent-kit:auto-coder code"

To resume THIS session (if interrupted):

  claude --resume "auto-coder: {PROJECT_NAME} | {TASK_ID}"

═══════════════════════════════════════════════════════════════════════════════
```

### Legacy Step 9: Handle Project Completion

When ALL features have `passes: true`:

```
═══════════════════════════════════════════════════════════════════════════════
                         PROJECT COMPLETE
═══════════════════════════════════════════════════════════════════════════════

All {TOTAL} features have been implemented and tested!

Summary:
  High priority:   {HIGH_TOTAL}/{HIGH_TOTAL} complete
  Medium priority: {MEDIUM_TOTAL}/{MEDIUM_TOTAL} complete
  Low priority:    {LOW_TOTAL}/{LOW_TOTAL} complete

Total commits: {COMMIT_COUNT}
First commit: {FIRST_HASH}
Final commit: {LAST_HASH}

═══════════════════════════════════════════════════════════════════════════════
                         RECOMMENDED NEXT STEPS
═══════════════════════════════════════════════════════════════════════════════

1. Run full test suite:
   {PROJECT_SPECIFIC_TEST_COMMAND}

2. Review the implementation:
   - Check .auto-coder/progress.md for session history
   - Review git log for commit history

3. Deploy or continue development manually

═══════════════════════════════════════════════════════════════════════════════
```

## Security Guidance

### Recommended Commands

Safe to use during implementation:

| Category | Commands |
|----------|----------|
| File ops | `ls`, `cat`, `head`, `tail`, `wc`, `grep` |
| Runtime | `npm`, `node`, `bun`, `python`, `pytest` |
| Version control | `git` |
| Process | `ps`, `lsof`, `sleep`, `pkill` (dev processes only) |

### Commands to Avoid

Exercise caution with:

- System modification commands (`sudo`, `chmod 777`, `rm -rf`)
- Network commands without clear purpose
- Commands affecting files outside project directory
- Commands that could expose secrets or credentials

## Error Handling

### Tests Failing

```
WARNING: Test step failed

Feature: {TASK_ID}
Step: {STEP_NUMBER}: {STEP_DESCRIPTION}
Result: FAILED

Do NOT mark this feature as complete.
Debug and fix the issue, then re-run all tests.
```

### Regression Found

```
WARNING: Regression detected

Feature: {TASK_ID} (previously passing)
Step: {STEP_NUMBER}: {STEP_DESCRIPTION}
Result: FAILED

Actions:
1. Marking {TASK_ID} as passes: false
2. Fixing regression before proceeding
3. Will re-run regression tests after fix
```

### Git Errors

```
Git error: {ERROR_MESSAGE}

Attempting recovery...
- Check: git status
- Check: git diff

If working directory is clean, commit may have succeeded.
Verify with: git log -1
```

### Interrupted Session

If resuming an interrupted session:

1. Check git status for uncommitted changes
2. Check feature_list.json for last completed feature
3. Determine if previous feature was:
   - Fully complete (commit exists) → Proceed to next
   - Partially complete → Continue implementation
   - Not started → Start fresh

## Validation Checklist

Before ending session, verify:

- [ ] All tests for current feature pass
- [ ] Feature marked as `passes: true` in feature_list.json
- [ ] `completed_at` timestamp is set
- [ ] Git commit created with descriptive message
- [ ] `commit_hash` updated in feature_list.json
- [ ] Summary counts are accurate
- [ ] Progress.md updated with session details
- [ ] Session renamed appropriately
- [ ] Completion message displayed with next steps
