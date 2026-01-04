---
description: Show all available git commands and usage
argument-hint: ""
---

# Git Plugin Help

Display formatted information about all available git workflow commands.

## Available Commands

Display the following to the user:

---

## Git Plugin Commands

### 1. `/git:init`
**Description:** Initialize a new local git repository
**Syntax:** `/git:init`
**Usage:** Run in an empty directory or confirm to reinitialize an existing repo

---

### 2. `/git:status`
**Description:** Show repository status and diff summary
**Syntax:** `/git:status [--short|-s]`
**Usage:**
- `/git:status` - Full status with diff summary
- `/git:status -s` - Condensed status output

---

### 3. `/git:new-branch`
**Description:** Create a new branch and switch to it
**Syntax:** `/git:new-branch <branch_name>`
**Usage:** `/git:new-branch feature-authentication`
**Notes:** If branch exists, you'll be prompted with options

---

### 4. `/git:commit`
**Description:** Commit changes with optional auto-staging or interactive file selection
**Syntax:** `/git:commit [message] [--all|-a] [--interactive|-i]`
**Usage:**
- `/git:commit "Add login feature"` - Commit staged changes
- `/git:commit -a "Fix bug"` - Stage all and commit
- `/git:commit -i` - Interactively select files to stage and commit
- `/git:commit -i "Update docs"` - Interactive mode with message

---

### 5. `/git:push`
**Description:** Push commits to remote repository
**Syntax:** `/git:push [remote] [branch]`
**Usage:**
- `/git:push` - Push to configured upstream
- `/git:push origin main` - Push to specific remote and branch
**Notes:** Requires confirmation before pushing

---

### 6. `/git:remote-init`
**Description:** Create a new GitHub repository and set as remote
**Syntax:** `/git:remote-init <repo_name> <private|public> [push]`
**Usage:**
- `/git:remote-init my-project private` - Create private repo
- `/git:remote-init my-app public push` - Create public repo and push
**Prerequisites:** Requires `gh` CLI installed and authenticated

---

### 7. `/git:help`
**Description:** Show this help information
**Syntax:** `/git:help`
**Usage:** `/git:help`

---

## Tips

- Commands with `[argument]` have optional arguments
- Commands with `<argument>` require the argument
- Use `-i` or `--interactive` for `commit` to select specific files
- Remote operations (`push`, `remote-init`) require confirmation
- The `gh` CLI is required for `remote-init` - install from https://cli.github.com/

---
