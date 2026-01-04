---
description: Commit changes with optional auto-staging or interactive file selection
argument-hint: [message] [--all|-a] [--interactive|-i]
---

# Git Commit

Commit staged changes with optional auto-staging or interactive file selection.

## Parse Arguments

Extract flags and message from `$ARGUMENTS`:

1. **Check for flags:**
   - `interactive_mode = false`
   - `auto_stage = false`

   - If `$ARGUMENTS` contains `--interactive` or `-i` → `interactive_mode = true`
   - If `$ARGUMENTS` contains `--all` or `-a` → `auto_stage = true`

2. **Extract commit message:**
   - Remove all flags (`--interactive`, `-i`, `--all`, `-a`) from `$ARGUMENTS`
   - Trim whitespace from remaining text
   - The result is the `commit_message`
   - If `commit_message` is empty → will prompt later

3. **Flag precedence:**
   - If both `-i` and `-a` are present, `interactive_mode` takes precedence
   - Interactive mode will stage only selected files, not all

## Interactive File Selection

If `interactive_mode = true`:

1. Run `git status --short` to list unstaged and untracked files
2. Parse the output to extract file paths
3. If no unstaged/untracked files:
   - Output: "No unstaged changes to select from. Use `-a` to stage all changes."
   - Skip to commit message step

4. Use AskUserQuestion (multi-select) to select files:
   - Question: "Select files to stage for commit:"
   - Options: List each file from `git status --short`
   - multiSelect: true

5. Stage selected files:
   - For each selected file, run `git add {{file_path}}`

## Auto-Stage All Changes

If `auto_stage = true` AND `interactive_mode = false`:

1. Run `git add -A` to stage all changes
2. If command fails, display error and abort

## Commit Message

1. If `commit_message` is not empty:
   - Use the provided message

2. If `commit_message` is empty:
   - Use AskUserQuestion to prompt:
     - Question: "Enter commit message:"
     - (Free text input expected)
   - If user provides empty message again, prompt again with note that message is required

## Execute Commit

1. Run `git commit -m "{{commit_message}}"`

2. Parse the output to extract the commit hash (usually shown as first 7 characters)

3. Output success message:
   - "Committed changes: {{commit_hash}}"
   - Include the commit message in the output

## Error Handling

**Nothing to commit:**
- If `git commit` returns "nothing to commit":
  - Output: "No changes to commit. Stage changes first or use `-a` to stage all."

**Empty commit message:**
- Keep prompting until valid message provided

**Commit fails:**
- Display the git error message
- Common issues:
  - Need to configure user.name/user.email → Suggest: `git config user.name "Name"` and `git config user.email "email@example.com"`

## Examples

**Commit with message (staged changes):**
```
/git:commit "Add user authentication feature"
→ Committed changes: a1b2c3d
```

**Auto-stage all and commit:**
```
/git:commit -a "Fix navigation bug"
→ Staged all changes
→ Committed changes: d4e5f6g
```

**Interactive file selection:**
```
/git:commit -i
→ Select files to stage:
  ☑ src/auth.ts
  ☑ src/login.tsx
  ☐ README.md
→ Enter commit message: Add authentication components
→ Committed changes: g7h8i9j
```

**Interactive with message:**
```
/git:commit -i "Update login flow"
→ Select files to stage:
  ☑ src/login.tsx
→ Committed changes: j1k2l3m
```

**No message provided:**
```
/git:commit -a
→ Enter commit message: Quick bug fix
→ Committed changes: m4n5o6p
```

## Notes

- Use `-i` for selective staging when you have mixed changes
- Use `-a` for quick commits of all modified tracked files
- Combine `-i` with a message to streamline the workflow
- If both `-i` and `-a` are present, interactive mode takes precedence
