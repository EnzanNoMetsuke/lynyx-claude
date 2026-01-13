# Testing Guide for Lynyx Claude Marketplace

This guide demonstrates how to test the lynyx-claude marketplace and its plugins.

## Overview

The lynyx-claude project provides a Claude Code plugin marketplace with two main plugins:
- **git**: Git workflow commands
- **lynyx-agent-kit**: Autonomous coding and specification tools

## Automated Testing

We've created comprehensive test suites to validate the marketplace structure, plugin configurations, and command definitions.

### Running All Tests

Run the complete test suite:

```bash
./run_tests.sh
```

This executes three test suites:
1. **Python Marketplace Validator** - Deep validation of JSON configs and markdown files
2. **Installation Validator** - Bash-based structure and documentation tests
3. **Claude CLI Validator** - Official Claude Code validation using the `claude` CLI

### Running Individual Test Suites

**Python validation suite:**
```bash
python3 test_marketplace.py
```

**Installation validation suite:**
```bash
bash test_installation.sh
```

**Claude CLI validation suite:**
```bash
bash test_claude_cli.sh
```

### Claude CLI Validation

The Claude CLI validation suite uses the official Claude Code CLI to validate manifests:

**Installation:**
The test suite automatically installs the Claude CLI if not present using:
- pnpm package: `pnpm add -g @anthropic-ai/claude-code` (if Node.js v18+ and pnpm are available)
- Official installer: `curl -fsSL https://claude.ai/install.sh | bash` (fallback)

**Validations performed:**
- Marketplace manifest: `claude plugin validate .claude-plugin/marketplace.json`
- Plugin manifests: `claude plugin validate plugins/*/`.claude-plugin/plugin.json`
- Complete structure: `claude plugin validate .`

This ensures the marketplace passes all official Claude Code validation checks.

## Manual Testing in Claude Code

Since this is a Claude Code marketplace, the actual functionality is tested by installing and using it in Claude Code.

### Step 1: Install Claude Code

Follow the official installation guide at: https://code.claude.com/

### Step 2: Add the Marketplace

Open Claude Code and add the marketplace using one of these methods:

**Method A: Via GitHub repository** (Recommended for public use)
```
/plugin marketplace add EnzanNoMetsuke/lynyx-claude
```

**Method B: Via Git URL**
```
/plugin marketplace add https://github.com/EnzanNoMetsuke/lynyx-claude.git
```

**Method C: Via local path** (For development)
```
/plugin marketplace add /path/to/lynyx-claude
```

### Step 3: List Available Plugins

View plugins from the marketplace:
```
/plugin marketplace list lynyx-claude
```

### Step 4: Install Plugins

Install the plugins you want to use:

```
/plugin install git@lynyx-claude
/plugin install lynyx-agent-kit@lynyx-claude
```

### Step 5: Test Commands

After installation, test the commands to ensure they work correctly.

#### Testing Git Plugin Commands

**Initialize a repository:**
```
/git:init
```

**Check repository status:**
```
/git:status
```

**Create a new branch:**
```
/git:new-branch feature/test-branch
```

**Commit changes:**
```
/git:commit -a "Test commit message"
```

**View all git commands:**
```
/git:help
```

#### Testing Lynyx Agent Kit Commands

**Interview about a specification:**
```
/lynyx-agent-kit:interview SPEC.md
```

**Initialize auto-coder:**
```
/lynyx-agent-kit:auto-coder init spec.md
```

**Check auto-coder status:**
```
/lynyx-agent-kit:auto-coder status
```

## Test Coverage

### What the Tests Validate

#### 1. Marketplace Configuration
- ✓ marketplace.json exists and is valid JSON
- ✓ Required fields present (name, version, description, owner, plugins)
- ✓ Owner information complete
- ✓ Plugins array properly structured
- ✓ Plugin source paths exist

#### 2. Plugin Manifests
- ✓ Each plugin has .claude-plugin/plugin.json
- ✓ Manifest is valid JSON
- ✓ Required fields present (name, description, version)
- ✓ Version follows semver format
- ✓ Name matches directory name

#### 3. Command Files
- ✓ Commands are in commands/ directory with .md extension
- ✓ Each command has YAML frontmatter
- ✓ Frontmatter includes description field
- ✓ Command has substantial content/instructions
- ✓ Markdown is properly formatted

#### 4. Skills
- ✓ Skills are in skills/<skill-name>/ directories
- ✓ Each skill has SKILL.md file
- ✓ SKILL.md has YAML frontmatter
- ✓ Frontmatter includes description field
- ✓ Skill has substantial content/instructions

#### 5. Documentation
- ✓ README.md exists
- ✓ Installation instructions present
- ✓ Plugin listing included
- ✓ All installation methods documented

#### 6. Version Consistency
- ✓ Marketplace version defined
- ✓ Plugin versions match between marketplace.json and plugin.json

#### 7. Official Claude Code Validation
- ✓ Marketplace manifest passes `claude plugin validate`
- ✓ All plugin manifests pass `claude plugin validate`
- ✓ Complete marketplace structure validated
- ✓ Compliance with official Claude Code standards

## Expected Test Results

When running `./run_tests.sh`, you should see:

```
✓ Python validation suite PASSED
✓ Installation validation suite PASSED
✓ Claude CLI validation suite PASSED

🎉 All test suites passed!
The marketplace is validated and ready for use.
```

**Total checks performed:** 138+ individual validations across all test suites
- Python validator: 76 checks
- Installation validator: 53 checks  
- Claude CLI validator: 9 checks

## Troubleshooting

### Tests Fail

If tests fail, review the error messages. Common issues:

1. **JSON syntax errors**: Validate JSON files with a JSON linter
2. **Missing files**: Ensure all referenced files exist
3. **Version mismatches**: Update version numbers in both locations
4. **Missing frontmatter**: Add YAML frontmatter to command/skill files

### Commands Don't Work in Claude Code

If commands don't appear after installation:

1. Verify marketplace was added successfully
2. Check plugins are installed: `/plugin list`
3. Restart Claude Code to refresh cache
4. Verify plugin versions match

### Plugin Updates Not Loading

If changes don't appear after editing:

1. Bump the version in `.claude-plugin/plugin.json`
2. Update version in `.claude-plugin/marketplace.json`
3. Restart Claude Code
4. Reinstall the plugin if needed

## Development Testing Workflow

When developing new commands or plugins:

1. Make your changes to the plugin files
2. Run automated tests: `./run_tests.sh`
3. Fix any validation errors
4. Bump plugin version numbers
5. Test manually in Claude Code
6. Commit and push changes

## CI/CD Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: Test Marketplace
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.x'
      - name: Run tests
        run: ./run_tests.sh
```

## Additional Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins-reference)
- [Slash Commands Guide](https://code.claude.com/docs/en/slash-commands)
- [Skills Guide](https://code.claude.com/docs/en/skills)

## Contributing

When submitting changes:

1. Ensure all tests pass: `./run_tests.sh`
2. Add tests for new functionality
3. Update documentation
4. Follow conventional commits format

## License

See the main README for license information.
