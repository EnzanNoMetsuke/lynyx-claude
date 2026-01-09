# Initializer Phase Instructions

This document provides detailed instructions for the Initializer Agent (Session 1) of the auto-coder workflow.

## Prerequisites

Before running initialization:

1. **Specification file must exist** - Created via `/lynyx-agent-kit:interview` command
2. **Project directory identified** - Either current directory or specified path

If no spec file exists, prompt the user:

> No specification file found. Please create one first using:
> ```
> /lynyx-agent-kit:interview SPEC.txt
> ```

## Initialization Steps

### Step 1: Read and Analyze Specification

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

### Step 2: Generate Project Prefix

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

### Step 3: Generate Feature List

Create `.auto-coder/feature_list.json` following [FEATURE_SCHEMA.md](FEATURE_SCHEMA.md).

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

### Step 4: Write Test Steps

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

**Bad steps (too vague):**

```json
"steps": [
  "Step 1: Test the login",
  "Step 2: Make sure it works"
]
```

**Step requirements:**

- Specific and actionable
- Independently verifiable
- Cover happy path and edge cases
- Include both action and expected result

### Step 5: Create Directory Structure

Create the `.auto-coder/` directory:

```bash
mkdir -p .auto-coder
```

Write the feature list:

```bash
# Write feature_list.json with proper formatting
```

Initialize `progress.md`:

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

### Step 6: Initialize Git Repository

If `.git` doesn't exist:

```bash
git init
```

Create `.gitignore` if needed (don't overwrite existing):

```gitignore
# Add project-appropriate ignores
node_modules/
.env
*.log
```

### Step 7: Create Initial Commit

Stage and commit the initialization:

```bash
git add .auto-coder/
git add .gitignore  # if created
# Add any other initialized project files

git commit -m "$(cat <<'EOF'
feat(auto-coder): initialize project with feature list

- Generated feature_list.json with {N} features from {SPEC_FILE}
- High priority: {HIGH}, Medium: {MEDIUM}, Low: {LOW}
- Created progress tracking in .auto-coder/
EOF
)"
```

### Step 8: Rename Session

Rename the current session for easy identification:

```
/rename auto-coder: initialize {PROJECT_NAME}
```

### Step 9: Output Completion Message

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

## Error Handling

### Missing Spec File

```
ERROR: No specification file found at {PATH}

Please create a specification first:
  /lynyx-agent-kit:interview SPEC.txt

Then run initialization again:
  /lynyx-agent-kit:auto-coder init SPEC.txt
```

### Existing feature_list.json

If `.auto-coder/feature_list.json` already exists:

```
WARNING: .auto-coder/feature_list.json already exists.

Options:
1. Resume coding with existing feature list (/lynyx-agent-kit:auto-coder code)
2. Overwrite and reinitialize (destroys existing progress)

What would you like to do?
```

Use AskUserQuestion to get user choice. Only overwrite with explicit confirmation.

### Git Errors

If git operations fail, provide helpful guidance:

```
Git error: {ERROR_MESSAGE}

Possible solutions:
- Ensure git is installed: git --version
- Configure user: git config user.name "Your Name"
- Configure email: git config user.email "you@example.com"
```

## Validation Checklist

Before completing initialization, verify:

- [ ] Spec file was read completely
- [ ] Project prefix was approved by user
- [ ] All spec requirements have corresponding features
- [ ] Features are ordered by critical path (priority + dependencies)
- [ ] Each feature has concrete, testable steps
- [ ] Step numbering is correct (Step 1, Step 2, etc. per feature)
- [ ] feature_list.json is valid JSON
- [ ] Summary counts match actual feature counts
- [ ] Git commit was created successfully
- [ ] Session was renamed appropriately
- [ ] Completion message with next steps was displayed
