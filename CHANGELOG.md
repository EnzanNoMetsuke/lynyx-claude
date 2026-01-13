## [1.1.0] - 2026-01-13

### 🚀 Features

- Add comprehensive test suite for marketplace validation
- Add Claude CLI validation test suite with official validation commands
- Add OS-specific PNPM_HOME detection for macOS, Linux, and Windows

### 🐛 Bug Fixes

- Address code review feedback - improve YAML parser docs and fix shell patterns
- *(tests)* Correct frontmatter checks in installation tests
- Correct AWK frontmatter detection logic in test_installation.sh

### 🚜 Refactor

- Use pnpm instead of npm for Claude CLI installation

### 📚 Documentation

- Add comprehensive testing documentation and test runner

### 🎨 Styling

- *(run_tests.sh)* Fix formatting issues in Final Test Summary table

### ⚙️ Miscellaneous Tasks

- Bump marketplace minor version from 1.0.0 to 1.1.0
- Remove DEMONSTRATION.md as it's unnecessary
## [1.0.1] - 2026-01-11

### 📚 Documentation

- Update README to reflect public marketplace and add comprehensive skill development guide
- Use generic spec pattern and add marketplace installation instructions
- Fix links and improve formatting in README
## [1.0.0] - 2026-01-11

### 🐛 Bug Fixes

- Update marketplace.json to match official Claude Code schema

### 📚 Documentation

- Update README with correct marketplace.json schema
- Update plugin README with category field

### ⚙️ Miscellaneous Tasks

- Update marketplace manifest to prepare for public release
- Update repo url in marketplace manifest
## [0.2.0] - 2026-01-09

### 🚀 Features

- Create new auto-coder skill

### 🐛 Bug Fixes

- Update prompt when running claude code to use proper full command invocation
- Update auto-coder command in all skill/command *.md files to use proper full command invocation
- Update interview.md and add app_spec_template.txt | closes #3

### 📚 Documentation

- Update plugin README to use proper full command invocation
- Fix typo in auto-coder spec

### ⚙️ Miscellaneous Tasks

- Ignore macOS files
- Ignore changelog update commits in release notes
- Ignore spec creation in release notes
- Bump lynyx-agent-kit version (patch)
- Add plugin versions to marketplace manifest
## [0.1.1] - 2026-01-04

### 📚 Documentation

- Updated project README
## [0.1.0] - 2026-01-04

### 🚀 Features

- Add git workflow commands plugin with 7 commands

### 🚜 Refactor

- Change to shared file with detailed interview instructions, also used by /interview command
- Remove interview skill and use custom slash command instead

### 📚 Documentation

- Add README files for project and plugin
- Add CHANGELOG.md for v0.1.0
