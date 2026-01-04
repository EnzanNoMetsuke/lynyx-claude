---
description: Create a new branch and switch to it
argument-hint: <branch_name>
---

# Git New Branch

Create a new branch from HEAD and switch to it.

## Parse Arguments

1. Extract the branch name from `$ARGUMENTS`
2. Trim any leading/trailing whitespace
3. If no argument provided:
   - Use AskUserQuestion to prompt:
     - Question: "Enter the name for the new branch:"
     - (Free text input expected)

## Check if Branch Exists

1. Use the Bash tool to check if the branch already exists:
   ```bash
   git rev-parse --verify {{branch_name}} 2>/dev/null && echo "exists" || echo "not_found"
   ```

2. If result is "exists":
   - Use AskUserQuestion with options:
     - Question: "Branch '{{branch_name}}' already exists. What would you like to do?"
     - Options:
       - "Switch to existing branch" - Checkout the existing branch
       - "Create with different name" - Prompt for a new name and retry
       - "Abort" - Cancel the operation

   - **If "Switch to existing branch":**
     - Run `git checkout {{branch_name}}`
     - Output: "Switched to existing branch '{{branch_name}}'"

   - **If "Create with different name":**
     - Use AskUserQuestion to get new branch name
     - Repeat the entire process with the new name

   - **If "Abort":**
     - Output: "Operation cancelled. No changes made."
     - Stop execution

## Create and Switch to Branch

If branch does not exist:

1. Run `git checkout -b {{branch_name}}`
2. Output success message:
   - "Created and switched to new branch '{{branch_name}}'"

## Error Handling

If `git checkout -b` fails:
- Display git error message
- Common issues:
  - Invalid branch name → Suggest valid format (alphanumeric, hyphens, underscores)
  - Uncommitted changes → Suggest stashing: `git stash`
  - Not in a git repository → Run `/git:init` first

## Examples

**Create new feature branch:**
```
/git:new-branch feature-authentication
→ Created and switched to new branch 'feature-authentication'
```

**Handle existing branch:**
```
/git:new-branch main
→ Branch 'main' already exists. What would you like to do?
→ User selects "Switch to existing branch"
→ Switched to existing branch 'main'
```

**No argument provided:**
```
/git:new-branch
→ Enter the name for the new branch: feature-login
→ Created and switched to new branch 'feature-login'
```
