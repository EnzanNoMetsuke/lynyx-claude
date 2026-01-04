---
description: Push commits to remote repository
argument-hint: [remote] [branch]
---

# Git Push

Push commits to a remote repository with confirmation.

## Parse Arguments

Extract remote and branch from `$ARGUMENTS`:

1. Split `$ARGUMENTS` by whitespace
2. First argument (if present) = `remote_name`
3. Second argument (if present) = `branch_name`

## Determine Remote and Branch

1. **Get current branch:**
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
   Store as `current_branch`

2. **Determine target branch:**
   - If `branch_name` was provided in arguments: use it
   - Otherwise: use `current_branch`

3. **Determine target remote:**
   - If `remote_name` was provided in arguments: use it
   - Otherwise: try to get upstream remote:
     ```bash
     git rev-parse --abbrev-ref @{u} 2>/dev/null
     ```
   - If upstream exists, extract remote name from result (format: `remote/branch`)
   - If no upstream, default to `origin`

## Check Upstream Tracking

1. Check if current branch has upstream:
   ```bash
   git rev-parse --abbrev-ref @{u} 2>/dev/null
   ```

2. If command fails (no upstream) AND no arguments provided:
   - Use AskUserQuestion:
     - Question: "Branch '{{current_branch}}' has no upstream tracking. Set upstream with `-u` flag?"
     - Options:
       - "Yes, set upstream" - Use `git push -u {{remote}} {{branch}}`
       - "No, just push" - Use `git push {{remote}} {{branch}}`
       - "Cancel" - Abort operation

   - Store choice for command building

## Show What Will Be Pushed

1. Get list of commits to push:
   ```bash
   git log {{remote}}/{{branch}}..HEAD --oneline 2>/dev/null
   ```

2. Count commits (number of lines in output)

3. If count = 0:
   - Output: "Everything up-to-date. Nothing to push."
   - Stop execution

## Confirm Push

Use AskUserQuestion:
- Question: "Push {{commit_count}} commit(s) to {{remote}}/{{branch}}?"
- Show brief summary of commits (first 3-5 commits)
- Options:
  - "Yes, push" - Proceed with push
  - "No, cancel" - Abort

If user selects "No, cancel":
- Output: "Push cancelled. No changes made to remote."
- Stop execution

## Execute Push

1. Build push command based on earlier decisions:
   - If setting upstream: `git push -u {{remote}} {{branch}}`
   - Otherwise: `git push {{remote}} {{branch}}`

2. Execute the command

3. If successful:
   - Output: "Successfully pushed to {{remote}}/{{branch}}"

## Error Handling

**Remote doesn't exist:**
- Display error: "Remote '{{remote}}' not found."
- Suggest: "Use `git remote -v` to see configured remotes"

**Push rejected (non-fast-forward):**
- Display git error message
- Suggest: "Pull changes first with `git pull {{remote}} {{branch}}`"
- Or suggest: "Use `git pull --rebase` to rebase your changes"

**Authentication failed:**
- Display error
- Suggest checking credentials/SSH keys
- For HTTPS: May need to update credentials
- For SSH: Check `ssh -T git@github.com`

**Network error:**
- Display error message
- Suggest checking internet connection

## Examples

**Push to default upstream:**
```
/git:push
→ Push 3 commit(s) to origin/main?
  a1b2c3d Add feature
  d4e5f6g Fix bug
  g7h8i9j Update docs
→ User selects "Yes, push"
→ Successfully pushed to origin/main
```

**Push to specific remote and branch:**
```
/git:push origin feature-branch
→ Push 1 commit(s) to origin/feature-branch?
  j1k2l3m Implement new UI
→ User selects "Yes, push"
→ Successfully pushed to origin/feature-branch
```

**Set upstream on first push:**
```
/git:push
→ Branch 'feature-x' has no upstream tracking. Set upstream with `-u` flag?
→ User selects "Yes, set upstream"
→ Push 2 commit(s) to origin/feature-x?
→ User selects "Yes, push"
→ Successfully pushed to origin/feature-x
```

**Nothing to push:**
```
/git:push
→ Everything up-to-date. Nothing to push.
```

## Notes

- Always requires user confirmation before pushing
- Shows commit summary so user knows what's being pushed
- Handles upstream tracking automatically
- Safe for first-time pushes of new branches
