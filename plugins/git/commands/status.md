---
description: Show repository status and diff summary
argument-hint: [--short|-s]
---

# Git Status

Display the current repository status with optional diff summary.

## Parse Arguments

Check if `$ARGUMENTS` contains `--short` or `-s` flag.

## Execution

### Default Mode (No Flags)

If no flags present:

1. Run `git status` to show working tree status
2. Run `git diff --stat` to show summary of changes

Display both outputs to the user.

### Short Mode (With `-s` or `--short`)

If `--short` or `-s` flag is present:

1. Run `git status --short` for condensed output

Display the output to the user.

## Examples

**Default status with diff summary:**
```
/git:status
```

**Short condensed status:**
```
/git:status -s
/git:status --short
```

## Notes

- This is a read-only operation (no confirmation needed)
- The default mode provides more detailed information about changes
- The short mode is useful for quick checks
