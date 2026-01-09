# Project Overview

This spec describes a new skill for use with Claude Code in the lynyx-agent-kit
plugin.

## Goal

This goal of this project is to take the concept codified at
[lynyx-auto-coder](https://github.com/EnzanNoMetsuke/lynyx-auto-coder) and
create a skill from it that can be used with Claude Code when the
lynyx-agent-kit plugin is installed.

**IMPORTANT**: Note that the purpose of the resulting skill is **NOT** to be a
demo, but rather to establish a reusable framework to initialize and execute
new projects to completion.

## Proposed Workflow

1. Build out a full project specification in a `SPEC.txt` file using the
   `/lynyx-agent-kit:interview` command based on the `app_spec_template.txt`
   example from the GitHub repository.
2. Run the Initializer Agent (Session 1) to read the `SPEC.txt` file
   (whichever is present) and generate a `feature_list.json` file from it (see
   `initializer_prompt.md` from the GitHub repo).
3. Run the Coding Agent (Session 2) to pick up where previous session left off,
   implement features one by one, and mark them as passing in
   `feature_list.json` if *ALL* tests associated each feature has passed
   successfully.

## CRITICAL CONSIDERATIONS

- Each session **MUST** run in a fresh context window
- Progress **MUST** be persisted via `feature_list.json`, git commits, and a
  `progress.md` file that is appended with a summary (in valid Markdown) for
  each completed feature.
- The Coding Agent **MUST** ensure that **ALL** tests for a feature pass
  before marking it as complete.
- The Coding Agent **MUST** only work on a single feature at a time, making a
  git commit when the feature is complete before moving on to the next feature.
- The Coding Agent **MUST** auto-continue between each sessions (delay of 3
  seconds).
- The Coding Agent **MUST** continue work until all features in
  `feature_list.json` are marked as passing.
- The skill **MUST** provide a `Ctrl + P` keyboard shortcut to pause, and
  allow the same command to resume when issued again. If this keyboard shortcut
  cannot be implemented by the plugin itself, clear step-by-step instructions
  **MUST** be provided to the user to guide them on how to implement it.

## Security

See [Security Model](https://github.com/EnzanNoMetsuke/lynyx-auto-coder#security-model)
for details.
