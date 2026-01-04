---
description: Interview me about a spec file to gather detailed requirements
argument-hint: spec_file
---

# Spec Interview

## Context

Parse $ARGUMENTS to get the following value(s):

- [spec_file]: Specification file from $ARGUMENTS

## Task

Read the spec file and conduct a thorough interview using the AskUserQuestion tool.

- If a spec file path is provided as an argument, use that file
- If no argument is provided, default to `SPEC.md` in the current project's root directory

See @skills/interview/interview-guide.md for detailed interview instructions.
