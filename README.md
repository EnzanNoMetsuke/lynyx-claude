# Claude Code Plugin Marketplace

A public Claude Code plugin marketplace providing custom development tools, workflows, and AI-powered automation skills.

## Overview

This project is a public marketplace for Claude Code plugins developed by Lynyx Consulting. It provides production-ready plugins for git workflows, specification-driven development, and autonomous coding capabilities. The marketplace can be used both as a public resource and as a local development environment for creating and testing new plugins.

## Project Structure

```
.
├── .claude-plugin/
│   └── marketplace.json         # Marketplace configuration
├── .specs/                      # Specification files for features
│   ├── SPEC-20260103_01-Development_Workflows.md
│   └── SPEC-20260107_01-Auto-Coder.md
├── plugins/                     # Plugin source directories
│   ├── git/                    # Git workflow commands plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json     # Plugin manifest
│   │   ├── commands/
│   │   │   ├── commit.md
│   │   │   ├── help.md
│   │   │   ├── init.md
│   │   │   ├── new-branch.md
│   │   │   ├── push.md
│   │   │   ├── remote-init.md
│   │   │   └── status.md
│   │   └── README.md
│   └── lynyx-agent-kit/        # Custom agent toolkit plugin
│       ├── .claude-plugin/
│       │   └── plugin.json     # Plugin manifest
│       ├── commands/
│       │   ├── examples/
│       │   │   └── app_spec_template.txt
│       │   ├── auto-coder.md
│       │   └── interview.md
│       ├── skills/
│       │   └── auto-coder/
│       │       ├── scripts/
│       │       ├── CODER.md
│       │       ├── FEATURE_SCHEMA.md
│       │       ├── INITIALIZER.md
│       │       └── SKILL.md    # Skill definition
│       └── README.md
├── .gitignore
├── CHANGELOG.md
├── CLAUDE.md                    # Project guidelines for Claude Code
├── cliff.toml                   # Changelog generator config
└── README.md                    # This file
```

## How It Works

### Public Marketplace

The `.claude-plugin/marketplace.json` file defines the public marketplace and registers all available plugins:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "lynyx-claude",
  "version": "1.0.0",
  "description": "A Claude Code plugin marketplace for custom development tools and workflows by Lynyx Consulting",
  "owner": {
    "name": "Lynyx Consulting",
    "email": "claude@lynyx.net",
    "url": "https://github.com/EnzanNoMetsuke/lynyx-claude"
  },
  "plugins": [
    {
      "name": "lynyx-agent-kit",
      "source": "./plugins/lynyx-agent-kit",
      "description": "Custom skills and tools for Claude Code",
      "category": "development"
    },
    {
      "name": "git",
      "source": "./plugins/git",
      "description": "Git workflow commands for common repository operations",
      "category": "development"
    }
  ]
}
```

The marketplace can be accessed both locally for development and publicly via GitHub.

### Plugin Cache

Plugins are cached at:
```
~/.claude/plugins/cache/lynyx-claude/<plugin-name>/<version>/
```

When you bump a plugin's version number, Claude Code creates a new cache entry and loads the updated plugin.

## Available Plugins

### lynyx-agent-kit

Custom commands and tools for development workflows, including specification-driven development and autonomous coding.

**Commands:**
- `/lynyx-agent-kit:interview [spec_file]` - Interactive spec interviewer
- `/lynyx-agent-kit:auto-coder init [spec_file]` - Initialize project with feature list from spec
- `/lynyx-agent-kit:auto-coder code` - Implement next incomplete feature
- `/lynyx-agent-kit:auto-coder status` - Show current progress without making changes

**Skills:**
- `auto-coder` - Autonomous multi-session feature development framework

See `plugins/lynyx-agent-kit/README.md` for details.

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

See `plugins/git/README.md` for details.

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

3. Add to marketplace configuration in `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "my-plugin",
     "source": "./plugins/my-plugin",
     "description": "Brief description",
     "category": "development"
   }
   ```
   Categories: `development`, `productivity`, `learning`, or `security`

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

### Adding a Skill

Skills are model-invoked capabilities that Claude automatically applies based on context. Unlike commands (which users explicitly invoke with `/plugin:command`), Skills are activated when Claude determines they're relevant to the user's request.

#### Skill Directory Structure

Skills must follow this specific filesystem structure:

```
plugins/my-plugin/
└── skills/
    └── my-skill/          # Skill directory (lowercase, hyphens only)
        ├── SKILL.md       # Required: Skill definition
        ├── reference.md   # Optional: Detailed documentation
        ├── examples.md    # Optional: Usage examples
        └── scripts/       # Optional: Utility scripts
            └── helper.py
```

#### Creating a SKILL.md File

The `SKILL.md` file is the only required file and has two parts: YAML metadata (frontmatter) and Markdown instructions.

**Basic Example:**

```markdown
---
name: my-skill
description: >
  Brief description of what this skill does and when to use it.
  Claude uses this to decide when to apply the skill automatically.
---

# My Skill

## Overview

Clear explanation of what this skill does.

## Instructions

Provide step-by-step guidance for Claude:

1. First, do this...
2. Then, check for...
3. Finally, output...

## Examples

Show concrete examples of using this skill.
```

**Available YAML Metadata Fields:**

- `name` (required): Skill name using lowercase letters, numbers, and hyphens only (max 64 characters)
- `description` (required): What the skill does and when to use it (max 1024 characters)
- `allowed-tools` (optional): Tools Claude can use without asking permission when this skill is active
- `model` (optional): Specific Claude model to use when this skill is active
- `context` (optional): Set to `fork` to run the skill in an isolated sub-agent context
- `agent` (optional): Agent type to use when `context: fork` is set
- `user-invocable` (optional): Whether the skill appears in slash command menu (defaults to `true`)

#### Progressive Disclosure with Supporting Files

To keep the main context focused, use **progressive disclosure**: put essential information in `SKILL.md` and detailed reference material in separate files. Claude will only load supporting files when needed.

**Example with supporting files:**

```markdown
---
name: code-reviewer
description: Review code changes using team standards
---

# Code Review Skill

## Overview

Reviews pull requests and code changes following our team's coding standards.

## Instructions

1. Read the code changes
2. Check against standards in [reference.md](reference.md)
3. Review examples in [examples.md](examples.md) for guidance
4. Provide feedback with specific line numbers

## Validation

To validate code style, run:
```bash
python scripts/style_checker.py <file>
```

The script checks formatting and returns errors without loading its source into context.
```

#### Testing Your Skill

1. Create the skill directory and `SKILL.md` file
2. Bump the plugin version in `.claude-plugin/plugin.json`
3. Restart Claude Code
4. Test by making requests that should trigger the skill

#### Reference Documentation

For complete guidance on creating Skills, see the [Anthropic Skills documentation](https://code.claude.com/docs/en/skills).

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

- **SPEC-20260103_01-Development_Workflows.md** - Git workflow commands specification

These specs document features and serve as requirements for implementation.

## Git Workflow

This is a git repository tracking plugin development. You can use either the git plugin commands or standard git CLI:

**Using the git plugin:**
```
/git:status              # View status
/git:commit -i          # Commit with interactive file selection
/git:push               # Push to remote
```

**Using standard git:**
```bash
git status              # View status
git add .              # Stage changes
git commit -m "..."    # Commit
git push               # Push to remote
```

**Note:** Follow [Conventional Commits](https://www.conventionalcommits.org/) format for all commits.

## References

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins-reference.md)
- [Slash Commands Guide](https://code.claude.com/docs/en/slash-commands.md)
- [Skills Guide](https://code.claude.com/docs/en/skills.md)

## Author

**lynyx**
support@lynyx.net
