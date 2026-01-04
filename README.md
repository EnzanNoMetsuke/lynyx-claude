# Claude Code Plugin Development Workspace

A local Claude Code plugin marketplace and development environment for custom plugins and skills.

## Overview

This project serves as a development workspace for custom Claude Code plugins. It's configured as a local marketplace, allowing rapid iteration and testing of plugins before publishing to a shared marketplace.

## Project Structure

```
.
├── .claude-plugin/
│   └── marketplace.json      # Local marketplace configuration
├── .specs/                   # Specification files for features
│   └── SPEC-*.md            # Individual feature specs
├── plugins/                  # Plugin source directories
│   └── lynyx-agent-kit/     # Custom agent toolkit plugin
│       ├── .claude-plugin/
│       │   └── plugin.json  # Plugin manifest
│       ├── commands/        # Slash commands
│       │   └── interview.md
│       └── README.md
├── CLAUDE.md                 # Project guidelines for Claude Code
└── README.md                 # This file
```

## How It Works

### Local Marketplace

The `.claude-plugin/marketplace.json` file registers local plugin directories:

```json
{
  "name": "lynyx-claude-plugins",
  "owner": {
    "name": "lynyx"
  },
  "plugins": [
    {
      "name": "lynyx-agent-kit",
      "source": "./plugins/lynyx-agent-kit",
      "description": "Custom skills and tools for Claude Code"
    }
  ]
}
```

When Claude Code starts in this directory, it automatically loads plugins from the local marketplace.

### Plugin Cache

Plugins are cached at:
```
~/.claude/plugins/cache/lynyx-claude-plugins/<plugin-name>/<version>/
```

When you bump a plugin's version number, Claude Code creates a new cache entry and loads the updated plugin.

## Available Plugins

### lynyx-agent-kit

Custom skills and tools for development workflows.

**Commands:**
- `/lynyx-agent-kit:interview` - Interactive spec interviewer

See `plugins/lynyx-agent-kit/README.md` for details.

## Development Workflow

### Creating a New Plugin

1. Create plugin directory:
   ```bash
   mkdir -p plugins/my-plugin/.claude-plugin
   mkdir -p plugins/my-plugin/commands
   ```

2. Create `plugin.json` manifest:
   ```json
   {
     "name": "my-plugin",
     "description": "Brief description",
     "version": "0.1.0",
     "author": {
       "name": "your-name",
       "email": "your-email"
     }
   }
   ```

3. Add to marketplace configuration in `.claude-plugin/marketplace.json`

4. Create commands in `plugins/my-plugin/commands/`

5. Restart Claude Code to load the plugin

### Adding a Command

Create a `.md` file in `commands/`:

```markdown
---
description: What this command does
argument-hint: [optional_args]
---

# Command Name

Instructions for Claude on how to execute this command.
```

### Testing Changes

1. Bump the version in `plugin.json`
2. Restart Claude Code
3. The new version will be cached and loaded

### Publishing

When ready to share:

1. Push plugin to a git repository
2. Create a public marketplace.json pointing to your repo
3. Share the marketplace URL with others

## Specifications

The `.specs/` directory contains living specification documents:

- **SPEC-20260103_01-Development_Workflows.md** - Git workflow skills specification

These specs document features and serve as requirements for implementation.

## Git Workflow

This is a git repository tracking plugin development:

```bash
# View status
git status

# Commit changes
git add .
git commit -m "Description of changes"

# Push to remote
git push
```

## References

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins-reference.md)
- [Slash Commands Guide](https://code.claude.com/docs/en/slash-commands.md)
- [Skills Guide](https://code.claude.com/docs/en/skills.md)

## Author

**lynyx**
support@lynyx.net
