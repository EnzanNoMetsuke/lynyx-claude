---
description: Autonomous feature development orchestrator - initialize, code, or check status
argument-hint: <init|code|status> [spec_file]
---

# Auto-Coder Command

Orchestrates autonomous multi-session feature development using the auto-coder skill.

**Usage:**

- `/lynyx-agent-kit:auto-coder init [spec_file]` - Initialize project with feature list from spec
- `/lynyx-agent-kit:auto-coder code` - Implement next incomplete feature
- `/lynyx-agent-kit:auto-coder status` - Show current progress without making changes

## Argument Parsing

1. **Parse the first argument** to determine mode:
   - `init` → Initializer phase
   - `code` → Coding phase
   - `status` → Status display
   - No argument or unrecognized → Show help

2. **For `init` mode**, check for optional second argument:
   - If provided: Use as spec file path
   - If not provided: Default to `SPEC.txt` in current directory

## Mode: `init`

**Purpose:** Initialize a new auto-coder project from a specification.

**Behavior:**

1. Verify spec file exists at the provided path (or `SPEC.txt`)
2. If spec doesn't exist, show error and suggest using `/lynyx-agent-kit:interview`
3. Check if `.auto-coder/feature_list.json` already exists
   - If exists, warn user and ask for confirmation to overwrite

### Initializer Phase Instructions

#### Step 1: Read and Analyze Specification

Thoroughly read the specification file to understand:

- Project goals and purpose
- Technology stack and constraints
- Feature requirements (functional and non-functional)
- UI/UX specifications
- Data models and API endpoints
- Success criteria

**Important:** Identify ALL requirements, including implicit ones. Look for:

- Dependencies between features
- Foundational requirements (authentication before protected routes)
- Technical prerequisites (database before CRUD operations)

#### Step 2: Generate Project Prefix

Auto-generate a task ID prefix from the project name:

**Algorithm:**

1. Extract significant words from project name
2. Create 2-5 character uppercase prefix
3. Ensure it's memorable and recognizable

**Examples:**

- "My Web Application" → `MWA` or `MYWEBAPP`
- "Todo List App" → `TODO` or `TLA`
- "E-Commerce Platform" → `ECOM` or `ECP`

**Present to user for approval:**

Use AskUserQuestion to confirm:

> I've analyzed your specification and will generate a feature list.
>
> **Project name:** `{extracted_name}`
> **Suggested prefix:** `{generated_prefix}`
>
> The prefix will be used for task IDs (e.g., {PREFIX}-001, {PREFIX}-002).
>
> Is this prefix acceptable, or would you like to use a different one?

Options:

- Use suggested prefix
- Enter custom prefix

#### Step 3: Generate Feature List

Create `.auto-coder/feature_list.json` following this schema:

```json
{
  "project": {
    "name": "string",
    "prefix": "string (e.g., MYAPP)",
    "spec_file": "string (path to spec)",
    "created_at": "ISO8601 timestamp",
    "last_updated": "ISO8601 timestamp"
  },
  "features": [
    {
      "id": "number (1-indexed, sequential)",
      "task_id": "string (e.g., MYAPP-001)",
      "category": "functional | style | non-functional",
      "priority": "high | medium | low",
      "description": "string (brief feature description)",
      "steps": [
        "Step 1: description of first test step",
        "Step 2: description of second test step"
      ],
      "passes": "boolean (false initially, true when complete)",
      "completed_at": "ISO8601 timestamp | null",
      "commit_hash": "string | null"
    }
  ],
  "summary": {
    "total": "number",
    "completed": "number",
    "remaining": "number",
    "by_priority": {
      "high": { "total": "number", "completed": "number" },
      "medium": { "total": "number", "completed": "number" },
      "low": { "total": "number", "completed": "number" }
    }
  }
}
```

**Feature Extraction Guidelines:**

1. **Scope appropriately** - Generate as many features as needed to comprehensively cover the spec
   - Small project: 20-50 features
   - Medium project: 50-100 features
   - Large project: 100-200+ features

2. **Categorize features:**
   - `functional` - Core application logic, API endpoints, user flows
   - `style` - Visual design, responsive layouts, animations
   - `non-functional` - Performance, security, accessibility

3. **Assign priorities:**
   - `high` - Core functionality, blockers for other features
   - `medium` - Important features, enhancements
   - `low` - Nice-to-haves, polish items

4. **Order by critical path:**
   - **Priority first**: All high → all medium → all low
   - **Dependencies within priority**: Features that others depend on come first
   - **Result**: Sequential implementation works without blocking

**Dependency Analysis:**

- Database setup before CRUD operations
- Authentication before protected routes
- API endpoints before frontend that consumes them
- Base components before composite components
- Configuration before features that use it

#### Step 4: Write Test Steps

For each feature, write 2-10 concrete test steps:

**Format:** `"Step N: <specific testable action or verification>"`

**Good steps:**

```json
"steps": [
  "Step 1: Navigate to /login page",
  "Step 2: Verify email and password input fields are present",
  "Step 3: Submit form with invalid credentials",
  "Step 4: Verify error message is displayed",
  "Step 5: Submit form with valid credentials",
  "Step 6: Verify redirect to /dashboard"
]
```

**Step requirements:**

- Specific and actionable
- Independently verifiable
- Cover happy path and edge cases
- Include both action and expected result

#### Step 5: Create Directory Structure

Create the `.auto-coder/` directory:

```bash
mkdir -p .auto-coder
```

Write the feature list and initialize `progress.md`:

```markdown
# Auto-Coder Progress Log

## Project: {PROJECT_NAME}
- **Spec file:** {SPEC_FILE}
- **Total features:** {TOTAL}
- **Task prefix:** {PREFIX}

---

## Session 1: Initialization
**Date:** {TIMESTAMP}

### Actions
- Analyzed specification: {SPEC_FILE}
- Generated feature list with {TOTAL} features
  - High priority: {HIGH_COUNT}
  - Medium priority: {MEDIUM_COUNT}
  - Low priority: {LOW_COUNT}
- Initialized project structure

### Initial Commit
- Hash: {COMMIT_HASH}

---
```

#### Step 6: Initialize Git Repository

If `.git` doesn't exist:

```bash
git init
```

Create `.gitignore` if needed (don't overwrite existing).

#### Step 7: Create Initial Commit

Stage and commit the initialization:

```bash
git add .auto-coder/
git add .gitignore  # if created
# Add any other initialized project files

git commit -m "feat(auto-coder): initialize project with feature list

- Generated feature_list.json with {N} features from {SPEC_FILE}
- High priority: {HIGH}, Medium: {MEDIUM}, Low: {LOW}
- Created progress tracking in .auto-coder/"
```

#### Step 8: Rename Session

Rename the current session for easy identification:

```
/rename auto-coder: initialize {PROJECT_NAME}
```

#### Step 9: Output Completion Message

Display completion summary and next steps:

```
═══════════════════════════════════════════════════════════════════════════════
                        INITIALIZATION COMPLETE
═══════════════════════════════════════════════════════════════════════════════

Project: {PROJECT_NAME}
Features: {TOTAL} ({HIGH} high, {MEDIUM} medium, {LOW} low priority)
Commit: {COMMIT_HASH}

Files created:
  .auto-coder/feature_list.json  - Feature tracking (source of truth)
  .auto-coder/progress.md        - Human-readable progress log

═══════════════════════════════════════════════════════════════════════════════
                              NEXT STEPS
═══════════════════════════════════════════════════════════════════════════════

To begin coding, start a NEW session and run:

  claude -p "/lynyx-agent-kit:auto-coder code"

For auto-continuation (runs until complete or interrupted):

  while true; do claude -p "/lynyx-agent-kit:auto-coder code" || break; sleep 3; done

To check progress at any time:

  claude -p "/lynyx-agent-kit:auto-coder status"

═══════════════════════════════════════════════════════════════════════════════
```

**Example:**

```
> /lynyx-agent-kit:auto-coder init SPEC.txt

Reading specification from SPEC.txt...
Analyzing requirements...

Project name: My Web App
Suggested prefix: MWA

Is this prefix acceptable? [Yes / Enter custom]

Generating feature list...
Created 47 features (15 high, 22 medium, 10 low priority)
Initialized git repository
Created commit: abc1234

INITIALIZATION COMPLETE
Next: claude -p "/lynyx-agent-kit:auto-coder code"
```

## Mode: `code`

**Purpose:** Implement the next incomplete feature.

**Behavior:**

1. Verify `.auto-coder/feature_list.json` exists
   - If not, show error and suggest running `init` first
2. If all features are complete, display project completion message

### Coding Phase Instructions

#### Prerequisites

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

#### Step 1: Orient to Project State

Read and understand current project state:

```bash
# Read feature list
cat .auto-coder/feature_list.json

# Read recent progress (last 50 lines)
tail -50 .auto-coder/progress.md

# Check git history
git log --oneline -10

# Check working directory status
git status
```

**Extract from feature_list.json:**

- Project name and prefix
- Total features and completion count
- Next incomplete feature (first with `passes: false`)
- Any uncommitted changes from interrupted session

#### Step 2: Regression Check (HIGH PRIORITY ONLY)

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

#### Step 3: Feature Selection

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

#### Step 4: Implementation

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

#### Step 5: Test Verification

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

#### Step 6: Update Feature List

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

#### Step 7: Git Commit

Create a descriptive commit for the completed feature:

```bash
git add -A

git commit -m "feat(auto-coder): {TASK_ID} - {DESCRIPTION}

Implements:
- {Specific change 1}
- {Specific change 2}
- {Specific change 3}

Tests: {N}/{N} passing"
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

#### Step 8: Update Progress Log

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

#### Step 9: Session Completion

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

#### Step 10: Handle Project Completion

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

### Security Guidance

**Recommended Commands (safe to use):**

| Category | Commands |
|----------|----------|
| File ops | `ls`, `cat`, `head`, `tail`, `wc`, `grep` |
| Runtime | `npm`, `node`, `bun`, `python`, `pytest` |
| Version control | `git` |
| Process | `ps`, `lsof`, `sleep`, `pkill` (dev processes only) |

**Commands to Avoid:**

- System modification commands (`sudo`, `chmod 777`, `rm -rf`)
- Network commands without clear purpose
- Commands affecting files outside project directory
- Commands that could expose secrets or credentials

### Error Handling

**Tests Failing:**

```
WARNING: Test step failed

Feature: {TASK_ID}
Step: {STEP_NUMBER}: {STEP_DESCRIPTION}
Result: FAILED

Do NOT mark this feature as complete.
Debug and fix the issue, then re-run all tests.
```

**Regression Found:**

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

**Interrupted Session:**

If resuming an interrupted session:

1. Check git status for uncommitted changes
2. Check feature_list.json for last completed feature
3. Determine if previous feature was:
   - Fully complete (commit exists) → Proceed to next
   - Partially complete → Continue implementation
   - Not started → Start fresh

### Validation Checklist

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

**Example:**

```
> /lynyx-agent-kit:auto-coder code

Reading project state...
Project: My Web App (MWA)
Progress: 5/47 features complete (10%)

Running regression tests on HIGH priority features...
✓ MWA-001: User authentication
✓ MWA-002: User registration
✓ MWA-003: Protected routes
All regression tests passed.

Next feature: MWA-006 - Dashboard layout
Renaming session: auto-coder: My Web App | MWA-006

Implementing...
[Implementation work happens here]

Running tests...
✓ Step 1: Dashboard page loads at /dashboard
✓ Step 2: User name displayed in header
✓ Step 3: Navigation sidebar present
✓ Step 4: Main content area responsive
All tests passed!

Updating feature list...
Creating commit: def5678

SESSION COMPLETE
Progress: 6/47 (12%)
Next: MWA-007 - Dashboard widgets
```

## Mode: `status`

**Purpose:** Display current project progress without making changes.

**Behavior:**

1. Check if `.auto-coder/feature_list.json` exists
   - If not, show message that no auto-coder project is initialized
2. Read and parse feature_list.json
3. Display formatted progress summary:
   - Project name and prefix
   - Overall completion (X/Y features, percentage)
   - Breakdown by priority
   - Last completed feature (if any)
   - Next feature to implement (if any)
   - Recent git commits related to auto-coder

**Example:**

```
> /lynyx-agent-kit:auto-coder status

═══════════════════════════════════════════════════════════════════════════════
                         AUTO-CODER STATUS
═══════════════════════════════════════════════════════════════════════════════

Project: My Web App
Prefix: MWA
Spec: SPEC.txt

Progress: 12/47 features complete (25%)

By Priority:
  High:   8/15 complete  [████████░░░░░░░] 53%
  Medium: 4/22 complete  [██░░░░░░░░░░░░░] 18%
  Low:    0/10 complete  [░░░░░░░░░░░░░░░]  0%

Last Completed:
  MWA-012: API error handling
  Commit: abc1234 (2 hours ago)

Next Feature:
  MWA-013: Loading states and spinners
  Category: style
  Priority: medium
  Steps: 5

═══════════════════════════════════════════════════════════════════════════════

To continue: claude -p "/lynyx-agent-kit:auto-coder code"
```

## Help (No Arguments)

If no valid mode is provided, display help:

```
═══════════════════════════════════════════════════════════════════════════════
                           AUTO-CODER
═══════════════════════════════════════════════════════════════════════════════

Autonomous multi-session feature development orchestrator.

USAGE:
  /lynyx-agent-kit:auto-coder init [spec_file]   Initialize project from specification
  /lynyx-agent-kit:auto-coder code               Implement next incomplete feature
  /lynyx-agent-kit:auto-coder status             Show current progress

WORKFLOW:
  1. Create spec:  /lynyx-agent-kit:interview SPEC.txt
  2. Initialize:   /lynyx-agent-kit:auto-coder init SPEC.txt
  3. Code:         /lynyx-agent-kit:auto-coder code (repeat until complete)

AUTO-CONTINUATION:
  while true; do claude -p "/lynyx-agent-kit:auto-coder code" || break; sleep 3; done

PAUSE/RESUME:
  Pause:  Ctrl+C or Ctrl+D
  Resume: claude --resume "auto-coder: {PROJECT} | {TASK_ID}"

═══════════════════════════════════════════════════════════════════════════════
```

## Error States

### No spec file found (init mode)

```
ERROR: Specification file not found: {PATH}

Create a specification first:
  /lynyx-agent-kit:interview SPEC.txt

Then initialize:
  /lynyx-agent-kit:auto-coder init SPEC.txt
```

### Not initialized (code/status mode)

```
ERROR: Auto-coder not initialized

No .auto-coder/feature_list.json found.

Initialize first:
  /lynyx-agent-kit:auto-coder init SPEC.txt
```

### Invalid mode

```
ERROR: Unknown command: {ARGUMENT}

Valid commands:
  init   - Initialize project from spec
  code   - Implement next feature
  status - Show progress

Run /lynyx-agent-kit:auto-coder without arguments for help.
```
