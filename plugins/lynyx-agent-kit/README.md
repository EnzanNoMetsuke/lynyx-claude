# lynyx-agent-kit

Custom skills and tools for Claude Code to streamline development workflows.

## Overview

The `lynyx-agent-kit` plugin provides specialized commands and workflows for common development tasks, starting with an interactive specification interview tool.

## Installation

### Via Local Marketplace

This plugin is configured in the local marketplace at `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    {
      "name": "lynyx-agent-kit",
      "source": "./plugins/lynyx-agent-kit",
      "description": "Custom skills and tools for Claude Code"
    }
  ]
}
```

The plugin is automatically loaded when Claude Code starts in this project.

### Manual Installation

To use this plugin in other projects:

1. Copy the `plugins/lynyx-agent-kit` directory to your target project
2. Add it to your project's marketplace configuration, or
3. Enable it in `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "lynyx-agent-kit@lynyx-claude-plugins": true
  }
}
```

## Commands

### `/lynyx-agent-kit:interview`

Interactive specification interviewer that helps gather detailed requirements through structured questioning.

**Usage:**
```
/lynyx-agent-kit:interview [spec_file]
```

**Arguments:**
- `spec_file` (optional): Path to the specification file to review. Defaults to `SPEC.md` in the project root.

**What it does:**
1. Reads the specified spec file
2. Conducts a thorough interview using the AskUserQuestion tool
3. Asks non-obvious questions about:
   - Edge cases and failure modes
   - Technical implementation tradeoffs
   - UI/UX considerations and user flows
   - Security and performance implications
   - Integration points and dependencies
   - Scalability concerns
   - Data models and state management
   - Error handling strategies
   - Testing approaches
4. Summarizes findings and updates the spec file with gathered information

**Examples:**

Interview about the default SPEC.md:
```
/lynyx-agent-kit:interview
```

Interview about a specific spec:
```
/lynyx-agent-kit:interview .specs/SPEC-20260103_01-Development_Workflows.md
```

### `/lynyx-agent-kit:auto-coder`

Autonomous multi-session feature development orchestrator. Systematically implements features from a specification across multiple Claude Code sessions.

**Usage:**
```
/lynyx-agent-kit:auto-coder init [spec_file]   # Initialize project from specification
/lynyx-agent-kit:auto-coder code               # Implement next incomplete feature
/lynyx-agent-kit:auto-coder status             # Show current progress
```

**Workflow:**

1. **Create specification** using the interview command:
   ```
   /lynyx-agent-kit:interview SPEC.txt
   ```

2. **Initialize auto-coder** to generate feature list:
   ```
   /lynyx-agent-kit:auto-coder init SPEC.txt
   ```
   - Analyzes spec and creates `feature_list.json` with test cases
   - Orders features by priority and dependency (critical path)
   - Generates unique task IDs (e.g., `MYAPP-001`, `MYAPP-002`)

3. **Run coding sessions** (one feature per session):
   ```
   /lynyx-agent-kit:auto-coder code
   ```
   - Runs regression tests on high-priority passing features
   - Implements next incomplete feature
   - Verifies all tests pass
   - Creates git commit
   - Updates progress tracking

4. **Auto-continue** until project completion:
   ```bash
   while true; do claude -p "/lynyx-agent-kit:auto-coder code" || break; sleep 3; done
   ```

**Session Management:**
- Sessions auto-named: `auto-coder: {PROJECT} | {TASK_ID}`
- Pause: `Ctrl+C` or `Ctrl+D`
- Resume interrupted: `claude --resume "auto-coder: {PROJECT} | {TASK_ID}"`
- Start fresh: `claude -p "/lynyx-agent-kit:auto-coder code"`

**Generated Files:**
```
.auto-coder/
├── feature_list.json   # Source of truth for features
└── progress.md         # Human-readable session log
```

## Plugin Structure

```
lynyx-agent-kit/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── interview.md         # Spec interview command
│   └── auto-coder.md        # Auto-coder orchestrator command
├── skills/
│   └── auto-coder/
│       ├── SKILL.md         # Core skill definition
│       ├── INITIALIZER.md   # Phase 1 instructions
│       ├── CODER.md         # Phase 2 instructions
│       ├── FEATURE_SCHEMA.md # JSON schema for feature_list.json
│       └── scripts/
│           └── continue.sh  # Auto-continuation helper
└── README.md                # This file
```

## Development

### Adding New Commands

Create a new `.md` file in the `commands/` directory:

```markdown
---
description: Brief description of what the command does
argument-hint: [optional_arg]
---

# Command Name

Instructions for Claude on how to execute this command.
```

Commands are automatically discovered and available as `/lynyx-agent-kit:command-name`.

### Version Bumping

Update the version in `.claude-plugin/plugin.json` to force a cache refresh:

```json
{
  "version": "1.x.x"
}
```

After updating, restart Claude Code to pick up the new version.

## Version History

- **1.2.0** - Added auto-coder skill for autonomous multi-session feature development
- **1.1.0** - Converted interview from skill to command, merged all interview logic into single command file
- **1.0.1** - Fixed JSON syntax error in plugin.json, added author metadata
- **1.0.0** - Initial release with interview skill

## Author

**lynyx**
support@lynyx.net

## License

Private use
