# Git Workflow Commands Plugin

A Claude Code plugin providing intuitive slash commands for common git workflows.

## Overview

The `git` plugin streamlines common git operations with user-friendly commands that include confirmations for destructive operations, interactive file selection for commits, and helpful error messages.

## Installation

This plugin is configured in the local marketplace at `../../.claude-plugin/marketplace.json`.

When Claude Code starts in the project root, the plugin is automatically loaded and available.

## Commands

### `/git:init`

Initialize a new local git repository.

**Usage:**
```
/git:init
```

**Behavior:**
- Checks for existing `.git` directory
- Prompts for confirmation if repository already exists
- Initializes git repository

---

### `/git:status`

Show repository status with optional diff summary.

**Usage:**
```
/git:status [--short|-s]
```

**Examples:**
```
/git:status          # Full status with diff summary
/git:status -s       # Condensed status output
```

---

### `/git:new-branch`

Create a new branch and switch to it.

**Usage:**
```
/git:new-branch <branch_name>
```

**Behavior:**
- Checks if branch already exists
- Offers options if branch exists (switch/rename/abort)
- Creates and switches to new branch

**Examples:**
```
/git:new-branch feature-login
/git:new-branch bugfix-navigation
```

---

### `/git:commit`

Commit changes with optional auto-staging or interactive file selection.

**Usage:**
```
/git:commit [message] [--all|-a] [--interactive|-i]
```

**Flags:**
- `--all` or `-a` - Stage all changes before committing
- `--interactive` or `-i` - Interactively select files to stage

**Examples:**
```
/git:commit "Add user authentication"
/git:commit -a "Fix navigation bug"
/git:commit -i
/git:commit -i "Update login flow"
```

**Behavior:**
- Interactive mode: Select specific files to stage
- Auto-stage mode: Stages all tracked changes
- Prompts for message if not provided
- Shows commit hash on success

---

### `/git:push`

Push commits to remote repository with confirmation.

**Usage:**
```
/git:push [remote] [branch]
```

**Examples:**
```
/git:push                    # Push to default upstream
/git:push origin main        # Push to specific remote/branch
```

**Behavior:**
- Shows commit summary before pushing
- Offers to set upstream if not configured
- Requires user confirmation
- Handles authentication errors gracefully

---

### `/git:remote-init`

Create a new GitHub repository and set it as the remote origin.

**Prerequisites:**
- GitHub CLI (`gh`) must be installed
- Must be authenticated with GitHub (`gh auth login`)

**Usage:**
```
/git:remote-init <repo_name> <private|public> [push]
```

**Arguments:**
- `repo_name` - Name for the new GitHub repository
- `private|public` - Repository visibility
- `push` (optional) - Push local commits after creation

**Examples:**
```
/git:remote-init my-project private
/git:remote-init open-source-tool public push
```

**Behavior:**
- Checks for `gh` CLI installation and authentication
- Handles existing remote 'origin' (offers to replace)
- Creates GitHub repository
- Sets as remote origin
- Optionally pushes commits

---

### `/git:help`

Display help information for all git commands.

**Usage:**
```
/git:help
```

---

## Features

### Smart Confirmations

Commands that modify remote state (`push`, `remote-init`) require user confirmation and show what will change before proceeding.

### Interactive File Selection

The `commit -i` command allows you to select specific files to stage using a checkbox interface.

### Error Guidance

All commands provide actionable error messages with suggestions:
- Missing prerequisites → Installation instructions
- Authentication failures → Auth setup guidance
- Conflicts → Resolution suggestions

### Prerequisite Checking

Commands verify required tools are installed and configured before executing:
- `remote-init` checks for `gh` CLI and authentication
- `push` checks for remote configuration
- All commands verify git repository exists

## Troubleshooting

### GitHub CLI Not Found

If `/git:remote-init` fails with "GitHub CLI not installed":

**macOS:**
```bash
brew install gh
```

**Linux:**
See https://github.com/cli/cli/blob/trunk/docs/install_linux.md

**Windows:**
See https://github.com/cli/cli#installation

### GitHub CLI Not Authenticated

Run:
```bash
gh auth login
```

Follow the prompts to authenticate with GitHub.

### Push Rejected (Non-Fast-Forward)

If push fails with "rejected" error:

```bash
# Pull and merge remote changes
git pull origin main

# Or rebase your changes
git pull --rebase origin main
```

Then try `/git:push` again.

### Uncommitted Changes Prevent Branch Switch

If `/git:new-branch` warns about uncommitted changes:

```bash
# Stash your changes
git stash

# Then create the branch
/git:new-branch feature-name

# Apply stashed changes
git stash pop
```

## Development

### Adding New Commands

1. Create a new `.md` file in `commands/`
2. Add YAML frontmatter:
   ```yaml
   ---
   description: Brief description of command
   argument-hint: <required> [optional]
   ---
   ```
3. Write command instructions
4. Bump version in `.claude-plugin/plugin.json`
5. Restart Claude Code

### Version History

- **1.0.0** - Initial release with 7 core commands

## Technical Details

**Plugin Structure:**
```
git/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── init.md
│   ├── status.md
│   ├── new-branch.md
│   ├── commit.md
│   ├── push.md
│   ├── remote-init.md
│   └── help.md
└── README.md
```

**Command Format:**
- Markdown files with YAML frontmatter
- Auto-discovered from `commands/` directory
- Invoked as `/git:command-name`

## Author

**lynyx**
support@lynyx.net

## License

Private use
