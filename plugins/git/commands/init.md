---
description: Initialize a new local git repository
argument-hint: ""
---

# Git Init

Initialize a new local git repository in the current directory.

## Check for Existing Repository

1. Use the Bash tool to check if a `.git` directory exists:
   ```bash
   test -d .git && echo "exists" || echo "not_found"
   ```

2. If the result is "exists":
   - Use AskUserQuestion to confirm before reinitializing:
     - Question: "A git repository already exists in this directory. Reinitializing will not remove any files but may reset repository settings. Proceed with reinitialization?"
     - Options:
       - "Yes" - Proceed with reinitialization
       - "No" - Abort without changes

   - If user selects "No", abort and inform them no changes were made

## Initialize Repository

1. If no repository exists OR user confirmed reinitialization:
   - Run `git init` using the Bash tool

2. Output success message:
   - "Git repository initialized successfully in {{current_directory}}"

## Error Handling

If `git init` fails:
- Display the error message from git
- Common issues:
  - Permission denied → Suggest checking directory permissions
  - Not in a valid directory → Ensure you're in a writable directory

## Examples

**Initialize in empty directory:**
```
/git:init
```

**Reinitialize existing repository:**
```
/git:init
→ Prompted for confirmation
→ User selects "Yes"
→ Repository reinitialized
```
