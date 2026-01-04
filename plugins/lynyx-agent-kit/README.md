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

## Plugin Structure

```
lynyx-agent-kit/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   └── interview.md         # Spec interview command
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

- **1.1.0** - Converted interview from skill to command, merged all interview logic into single command file
- **1.0.1** - Fixed JSON syntax error in plugin.json, added author metadata
- **1.0.0** - Initial release with interview skill

## Author

**lynyx**
support@lynyx.net

## License

Private use
