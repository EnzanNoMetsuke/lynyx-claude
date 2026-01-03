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
    skills/
      <skill-name>/
        SKILL.md       # Skill definition and instructions
    agents/            # (optional) Custom agent definitions
```

### Key Concepts

- **Marketplace**: The root `.claude-plugin/marketplace.json` acts as a registry pointing to local plugin directories
- **Plugins**: Self-contained packages in `plugins/` that group related skills and agents
- **Skills**: Markdown-based instructions in `SKILL.md` files that extend Claude's capabilities with specialized workflows

### Adding New Content

**New Plugin:**
1. Create `plugins/<plugin-name>/.claude-plugin/plugin.json` with name, description, and version
2. Register the plugin in `.claude-plugin/marketplace.json` under the `plugins` array
3. Add skills and/or agents as subdirectories

**New Skill:**
1. Create `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`
2. Include YAML frontmatter with `description` field
3. Write clear instructions for how Claude should execute the skill

## Current Plugins

- **lynyx-agent-kit**: Custom skills and tools including an interview skill for gathering detailed spec requirements
