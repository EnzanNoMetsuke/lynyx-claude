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
4. Follow the instructions in `skills/auto-coder/INITIALIZER.md`:
   - Read and analyze spec
   - Generate project prefix (ask user for approval)
   - Create feature_list.json with features ordered by critical path
   - Initialize git if needed
   - Create initial commit
   - Rename session: `auto-coder: initialize {PROJECT_NAME}`
   - Display completion message with next steps

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

**Purpose:** Implement the next incomplete feature using sub-agents to optimize context usage.

**Behavior:**

1. Verify `.auto-coder/feature_list.json` exists
   - If not, show error and suggest running `init` first
2. **Spawn Task Selector sub-agent** (`agents/task-selector.md`):
   - Reads `feature_list.json` and reports next task in compact format
   - Returns project info, next task details, and high-priority passing features
   - Prevents main agent context from being filled with full feature list
3. **Handle Task Selector response**:
   - If `status: COMPLETE` → Display project completion message
   - If `status: NOT_INITIALIZED` or `status: ERROR` → Show error and abort
   - Otherwise → Proceed to implementation
4. **Spawn Task Implementer sub-agent** (`agents/task-implementer.md`):
   - Pass task details from Task Selector
   - Handles regression testing, implementation, testing, and commit
   - Returns completion status and progress
5. **Handle Implementer response**:
   - If `status: SUCCESS` → Display completion message with next steps
   - If `status: REGRESSION_FOUND` → Report regression and abort
   - If `status: TESTS_FAILED` → Report failed tests and abort
   - If `status: ERROR` → Display error and abort

**Example:**

```
> /lynyx-agent-kit:auto-coder code

[Spawning Task Selector agent...]

TASK_SELECTOR_REPORT
---
project_name: My Web App
project_prefix: MWA
progress: 5/47
next_task:
  id: MWA-006
  description: Dashboard layout
  ...
---
END_REPORT

[Spawning Task Implementer agent with task MWA-006...]

TASK_IMPLEMENTER_REPORT
---
status: SUCCESS
task_id: MWA-006
description: Dashboard layout
tests_passed: 4/4
commit_hash: def5678
progress: 6/47
next_task_id: MWA-007
---
END_REPORT

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
