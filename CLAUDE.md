# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **local Claude Code plugin marketplace** that serves as a development workspace for custom Claude Code plugins and skills. The marketplace configuration points to local plugin directories, allowing for rapid iteration during plugin development.

## Architecture

### Directory Structure

```
.claude-plugin/
  marketplace.json     # Marketplace manifest - registers all local plugins

plugins/
  <plugin-name>/
    .claude-plugin/
      plugin.json      # Plugin manifest (name, description, version)
    commands/
      <command-name>.md  # Command implementation (slash command)
    skills/              # (optional) Model-invoked skills
      <skill-name>/
        SKILL.md       # Skill definition and instructions
    agents/            # (optional) Custom agent definitions
```

### Key Concepts

- **Marketplace**: The root `.claude-plugin/marketplace.json` acts as a registry pointing to local plugin directories
- **Plugins**: Self-contained packages in `plugins/` that group related commands, skills, and agents
- **Commands**: User-invoked slash commands in `commands/*.md` files with YAML frontmatter (e.g., `/plugin-name:command-name`)
- **Skills**: Model-invoked workflows that Claude automatically applies based on context matching

### Adding New Content

**New Plugin:**
1. Create `plugins/<plugin-name>/.claude-plugin/plugin.json` with name, description, and version
2. Register the plugin in `.claude-plugin/marketplace.json` under the `plugins` array
3. Add commands, skills, and/or agents as needed

**New Command:**
1. Create `plugins/<plugin-name>/commands/<command-name>.md`
2. Include YAML frontmatter with `description` and `argument-hint`
3. Write instructions for Claude on how to execute the command
4. Command becomes available as `/plugin-name:command-name`

**New Skill:**
1. Create `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`
2. Include YAML frontmatter with `description` field
3. Write instructions for how Claude should execute the skill (model-invoked)

### Version Bumping

When making changes to a plugin:
1. Update the `version` field in `.claude-plugin/plugin.json`
2. Restart Claude Code to force cache refresh and load the new version

## Current Plugins

### lynyx-agent-kit
Custom commands and tools for development workflows.

**Commands:**
- `/lynyx-agent-kit:interview [spec_file]` - Interactive spec interviewer

### git
Git workflow commands for common repository operations.

**Commands:**
- `/git:init` - Initialize local git repository
- `/git:status [--short|-s]` - Show status and diff summary
- `/git:new-branch <branch_name>` - Create and switch to branch
- `/git:commit [message] [--all|-a] [--interactive|-i]` - Commit with options
- `/git:push [remote] [branch]` - Push to remote with confirmation
- `/git:remote-init <repo_name> <private|public> [push]` - Create GitHub repo
- `/git:help` - Show all git commands
