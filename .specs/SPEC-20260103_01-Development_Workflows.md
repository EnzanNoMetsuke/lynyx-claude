# SPECIFICATION: Claude Code Development Workflow Commands

This spec defines a `git` plugin for Claude Code containing commands to streamline common git workflows.

**Legend**:
- Angle brackets denote a required argument (e.g. `<required_arg>`)
- Square brackets denote an optional argument (e.g. `[optional_arg]`)

**Global Conventions**:
- All commands output a brief success confirmation message
- Destructive operations (remote changes) require user confirmation before executing
- The plugin name is `git`, so all triggers are `/git:<skill>`

---

## DEV-SKILL-01: Local Git Repository Initialization

Initialize a new local git repository in the current project directory.

- **Trigger:** `/git:init`
- **Command:** `git init`

### Behavior

1. Check if `.git` directory already exists
2. If exists: warn user and ask for confirmation before reinitializing
3. If not exists: run `git init`
4. Output brief success confirmation

---

## DEV-SKILL-02: Remote Git Repository Creation (GitHub)

Create a new GitHub repository from the current project directory using the `gh` CLI.

- **Trigger:** `/git:remote-init <repo_name> <private|public> [push]`
- **Command:** `gh repo create {{repo_name}} --{{visibility}} --source=. --remote=origin [--push]`

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `repo_name` | Yes | Name of the GitHub repository to create |
| `private\|public` | Yes | Repository visibility |
| `push` | No | If present, push local commits to remote after creation |

### Behavior

1. **Check prerequisites:** Detect if `gh` CLI is installed and authenticated
   - If not installed: provide installation instructions
   - If not authenticated: provide `gh auth login` guidance
2. **Check for existing remote:** If remote named `origin` already exists:
   - Prompt user with options: replace existing remote OR abort (no changes made)
3. **Confirm before executing:** Show the command that will run and ask for confirmation
4. Run the `gh repo create` command
5. Output brief success confirmation with repository URL

### Examples

```
/git:remote-init acme-widgets private push
```
→ `gh repo create acme-widgets --private --source=. --remote=origin --push`

```
/git:remote-init admiral-ackbar public
```
→ `gh repo create admiral-ackbar --public --source=. --remote=origin`

---

## DEV-SKILL-03: Create New Branch & Switch

Create a new branch from HEAD and switch to it.

- **Trigger:** `/git:new-branch <branch_name>`
- **Command:** `git checkout -b {{branch_name}}`

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `branch_name` | Yes | Name of the new branch |

### Behavior

1. Check if branch name already exists
2. If exists: show error and prompt user with options:
   - Switch to existing branch
   - Create a new branch with a different name (prompt for new name)
3. If not exists: create and switch to new branch
4. Output brief success confirmation

### Examples

```
/git:new-branch feature-signup-form
```
→ `git checkout -b feature-signup-form`

---

## DEV-SKILL-04: Commit Changes

Commit staged changes with a message. Supports optional auto-staging and interactive file selection.

- **Trigger:** `/git:commit [message] [--all|-a] [--interactive|-i]`
- **Command:** `git commit -m "{{message}}"` (with optional `git add` operations)

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `message` | No | Commit message. If omitted, prompt interactively |
| `--all`, `-a` | No | Stage all changes before committing |
| `--interactive`, `-i` | No | Interactively select files to stage |

### Behavior

1. If `--interactive` flag present:
   - List all unstaged/untracked files using AskUserQuestion (file-level granularity)
   - Allow user to select which files to stage
   - Stage selected files
2. If `--all` flag present:
   - Run `git add -A` to stage all changes
3. If no commit message provided:
   - Prompt user for commit message interactively
4. Run `git commit -m "{{message}}"`
5. Output brief success confirmation with commit hash

### Examples

```
/git:commit "Add user authentication"
```
→ `git commit -m "Add user authentication"`

```
/git:commit -a "Fix login bug"
```
→ `git add -A && git commit -m "Fix login bug"`

```
/git:commit -i
```
→ Interactive file selection, then prompt for message, then commit

---

## DEV-SKILL-05: Push to Remote

Push commits to a remote repository.

- **Trigger:** `/git:push [remote] [branch]`
- **Command:** `git push [{{remote}}] [{{branch}}]`

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `remote` | No | Remote name (default: current upstream or `origin`) |
| `branch` | No | Branch name (default: current branch) |

### Behavior

1. If current branch has no upstream tracking:
   - Prompt user: set upstream with `-u` flag, or abort
2. **Confirm before executing:** Show what will be pushed and ask for confirmation
3. Run `git push` with appropriate arguments
4. Output brief success confirmation

### Examples

```
/git:push
```
→ `git push` (to configured upstream)

```
/git:push origin feature-branch
```
→ `git push origin feature-branch`

---

## DEV-SKILL-06: Show Status

Display repository status and diff summary.

- **Trigger:** `/git:status [--short|-s]`
- **Command:** `git status` + `git diff --stat`

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--short`, `-s` | No | Show condensed status output |

### Behavior

**Default output:**
1. Run `git status`
2. Run `git diff --stat` to show changed file summary

**With `--short` flag:**
1. Run `git status --short`

### Examples

```
/git:status
```
→ Full status with diff stat

```
/git:status -s
```
→ Condensed status output

---

## DEV-SKILL-07: Help

Display all available git commands and their usage.

- **Trigger:** `/git:help`

### Behavior

1. List all git commands with:
   - Trigger syntax
   - Brief description
   - Available flags/arguments

---

## Plugin Structure

```
plugins/
  git/
    .claude-plugin/
      plugin.json
    commands/
      init/
        SKILL.md
      remote-init/
        SKILL.md
      new-branch/
        SKILL.md
      commit/
        SKILL.md
      push/
        SKILL.md
      status/
        SKILL.md
      help/
        SKILL.md
```

---

## Open Questions

_None at this time._

---

## Revision History

| Date | Changes |
|------|---------|
| 2026-01-03 | Initial spec with 3 commands |
| 2026-01-03 | Expanded to 7 commands based on interview; added behavior details, error handling, and confirmation requirements |
