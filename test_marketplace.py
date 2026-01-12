#!/usr/bin/env python3
"""
Test suite for the lynyx-claude marketplace and plugins.

This script validates:
1. Marketplace configuration structure and validity
2. Plugin manifest files
3. Command file structure and frontmatter
4. Skill definition files
5. Cross-references between files
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# ANSI color codes for output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'


class TestResult:
    """Store test results."""
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.warnings = 0
        self.errors = []
        
    def add_pass(self, test_name: str):
        self.passed += 1
        print(f"{GREEN}✓{RESET} {test_name}")
        
    def add_fail(self, test_name: str, error: str):
        self.failed += 1
        self.errors.append((test_name, error))
        print(f"{RED}✗{RESET} {test_name}")
        print(f"  {RED}Error: {error}{RESET}")
        
    def add_warning(self, test_name: str, warning: str):
        self.warnings += 1
        print(f"{YELLOW}⚠{RESET} {test_name}")
        print(f"  {YELLOW}Warning: {warning}{RESET}")
        
    def print_summary(self):
        print(f"\n{BLUE}{'='*60}{RESET}")
        print(f"{BLUE}Test Summary{RESET}")
        print(f"{BLUE}{'='*60}{RESET}")
        print(f"{GREEN}Passed: {self.passed}{RESET}")
        print(f"{RED}Failed: {self.failed}{RESET}")
        print(f"{YELLOW}Warnings: {self.warnings}{RESET}")
        
        if self.failed > 0:
            print(f"\n{RED}Failed Tests:{RESET}")
            for test_name, error in self.errors:
                print(f"  - {test_name}: {error}")
                
        return self.failed == 0


def parse_yaml_frontmatter(content: str) -> Tuple[Dict, str]:
    """Parse YAML frontmatter from markdown content."""
    if not content.startswith('---'):
        return {}, content
        
    parts = content.split('---', 2)
    if len(parts) < 3:
        return {}, content
        
    frontmatter = {}
    yaml_content = parts[1].strip()
    
    # Simple YAML parser for our needs
    lines = yaml_content.split('\n')
    current_key = None
    multiline_value = []
    
    for line in lines:
        stripped = line.strip()
        
        # Check if this is a key-value line
        if ':' in stripped and not stripped.startswith(' '):
            # Save previous multiline value if any
            if current_key and multiline_value:
                frontmatter[current_key] = ' '.join(multiline_value).strip()
                multiline_value = []
            
            key, value = stripped.split(':', 1)
            key = key.strip()
            value = value.strip()
            
            # Handle multi-line values with >
            if value == '>':
                current_key = key
                multiline_value = []
            elif value:
                # Single line value
                if value.startswith('"') and value.endswith('"'):
                    value = value[1:-1]
                elif value.startswith("'") and value.endswith("'"):
                    value = value[1:-1]
                frontmatter[key] = value
                current_key = None
            else:
                current_key = key
        elif current_key and stripped:
            # This is a continuation line for a multiline value
            multiline_value.append(stripped)
    
    # Save final multiline value if any
    if current_key and multiline_value:
        frontmatter[current_key] = ' '.join(multiline_value).strip()
            
    body = parts[2].strip()
    return frontmatter, body


def test_marketplace_config(results: TestResult):
    """Test the marketplace.json configuration."""
    print(f"\n{BLUE}Testing Marketplace Configuration{RESET}")
    print(f"{BLUE}{'─'*60}{RESET}")
    
    marketplace_path = Path('.claude-plugin/marketplace.json')
    
    # Check file exists
    if not marketplace_path.exists():
        results.add_fail("Marketplace file exists", "marketplace.json not found")
        return
    results.add_pass("Marketplace file exists")
    
    # Parse JSON
    try:
        with open(marketplace_path, 'r') as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        results.add_fail("Marketplace JSON valid", f"Invalid JSON: {e}")
        return
    results.add_pass("Marketplace JSON valid")
    
    # Check required fields
    required_fields = ['name', 'version', 'description', 'owner', 'plugins']
    for field in required_fields:
        if field not in config:
            results.add_fail(f"Marketplace has '{field}' field", f"Missing required field")
        else:
            results.add_pass(f"Marketplace has '{field}' field")
            
    # Check owner structure
    if 'owner' in config:
        owner_fields = ['name', 'email']
        for field in owner_fields:
            if field not in config['owner']:
                results.add_fail(f"Owner has '{field}' field", f"Missing owner field")
            else:
                results.add_pass(f"Owner has '{field}' field")
                
    # Check plugins array
    if 'plugins' in config:
        if not isinstance(config['plugins'], list):
            results.add_fail("Plugins is array", "plugins must be an array")
        else:
            results.add_pass("Plugins is array")
            
            if len(config['plugins']) == 0:
                results.add_warning("Plugins array not empty", "No plugins defined")
            else:
                results.add_pass(f"Plugins array has {len(config['plugins'])} plugin(s)")
                
                # Test each plugin entry
                for idx, plugin in enumerate(config['plugins']):
                    plugin_name = plugin.get('name', f'plugin-{idx}')
                    plugin_fields = ['name', 'source', 'description', 'category']
                    
                    for field in plugin_fields:
                        if field not in plugin:
                            results.add_fail(f"Plugin '{plugin_name}' has '{field}'", 
                                           f"Missing field in plugin entry")
                        else:
                            results.add_pass(f"Plugin '{plugin_name}' has '{field}'")
                            
                    # Check source path exists
                    if 'source' in plugin:
                        source_path = Path(plugin['source'])
                        if not source_path.exists():
                            results.add_fail(f"Plugin '{plugin_name}' source exists",
                                           f"Source path not found: {plugin['source']}")
                        else:
                            results.add_pass(f"Plugin '{plugin_name}' source exists")
                            
    return config if 'plugins' in config else {'plugins': []}


def test_plugin_manifest(plugin_path: Path, results: TestResult):
    """Test a plugin's manifest file."""
    plugin_name = plugin_path.name
    manifest_path = plugin_path / '.claude-plugin' / 'plugin.json'
    
    # Check manifest exists
    if not manifest_path.exists():
        results.add_fail(f"Plugin '{plugin_name}' manifest exists", 
                        "plugin.json not found")
        return None
    results.add_pass(f"Plugin '{plugin_name}' manifest exists")
    
    # Parse JSON
    try:
        with open(manifest_path, 'r') as f:
            manifest = json.load(f)
    except json.JSONDecodeError as e:
        results.add_fail(f"Plugin '{plugin_name}' manifest JSON valid", 
                        f"Invalid JSON: {e}")
        return None
    results.add_pass(f"Plugin '{plugin_name}' manifest JSON valid")
    
    # Check required fields
    required_fields = ['name', 'description', 'version']
    for field in required_fields:
        if field not in manifest:
            results.add_fail(f"Plugin '{plugin_name}' manifest has '{field}'",
                           f"Missing required field")
        else:
            results.add_pass(f"Plugin '{plugin_name}' manifest has '{field}'")
            
    # Check name matches directory
    if 'name' in manifest and manifest['name'] != plugin_name:
        results.add_warning(f"Plugin '{plugin_name}' name matches directory",
                          f"Name '{manifest['name']}' doesn't match directory '{plugin_name}'")
    elif 'name' in manifest:
        results.add_pass(f"Plugin '{plugin_name}' name matches directory")
        
    # Check version format (semver)
    if 'version' in manifest:
        version = manifest['version']
        if not re.match(r'^\d+\.\d+\.\d+', version):
            results.add_warning(f"Plugin '{plugin_name}' version is semver",
                              f"Version '{version}' should follow semver format")
        else:
            results.add_pass(f"Plugin '{plugin_name}' version is semver")
            
    return manifest


def test_command_file(command_path: Path, plugin_name: str, results: TestResult):
    """Test a command file."""
    command_name = command_path.stem
    
    # Read file
    try:
        with open(command_path, 'r') as f:
            content = f.read()
    except Exception as e:
        results.add_fail(f"Command '{plugin_name}:{command_name}' readable",
                        f"Cannot read file: {e}")
        return
    results.add_pass(f"Command '{plugin_name}:{command_name}' readable")
    
    # Parse frontmatter
    frontmatter, body = parse_yaml_frontmatter(content)
    
    if not frontmatter:
        results.add_fail(f"Command '{plugin_name}:{command_name}' has frontmatter",
                        "No YAML frontmatter found")
        return
    results.add_pass(f"Command '{plugin_name}:{command_name}' has frontmatter")
    
    # Check required frontmatter fields
    if 'description' not in frontmatter:
        results.add_fail(f"Command '{plugin_name}:{command_name}' has description",
                        "Missing 'description' in frontmatter")
    else:
        results.add_pass(f"Command '{plugin_name}:{command_name}' has description")
        
    # Check body has content
    if not body or len(body.strip()) < 10:
        results.add_fail(f"Command '{plugin_name}:{command_name}' has content",
                        "Command body is empty or too short")
    else:
        results.add_pass(f"Command '{plugin_name}:{command_name}' has content")


def test_skill_file(skill_path: Path, plugin_name: str, results: TestResult):
    """Test a skill definition file."""
    skill_name = skill_path.parent.name
    
    # Check SKILL.md exists
    skill_md_path = skill_path / 'SKILL.md'
    if not skill_md_path.exists():
        results.add_fail(f"Skill '{plugin_name}:{skill_name}' has SKILL.md",
                        "SKILL.md file not found")
        return
    results.add_pass(f"Skill '{plugin_name}:{skill_name}' has SKILL.md")
    
    # Read file
    try:
        with open(skill_md_path, 'r') as f:
            content = f.read()
    except Exception as e:
        results.add_fail(f"Skill '{plugin_name}:{skill_name}' readable",
                        f"Cannot read file: {e}")
        return
    results.add_pass(f"Skill '{plugin_name}:{skill_name}' readable")
    
    # Parse frontmatter
    frontmatter, body = parse_yaml_frontmatter(content)
    
    if not frontmatter:
        results.add_fail(f"Skill '{plugin_name}:{skill_name}' has frontmatter",
                        "No YAML frontmatter found")
        return
    results.add_pass(f"Skill '{plugin_name}:{skill_name}' has frontmatter")
    
    # Check required frontmatter fields
    required_fields = ['description']
    for field in required_fields:
        if field not in frontmatter:
            results.add_fail(f"Skill '{plugin_name}:{skill_name}' has '{field}'",
                           f"Missing '{field}' in frontmatter")
        else:
            results.add_pass(f"Skill '{plugin_name}:{skill_name}' has '{field}'")
            
    # Check body has content
    if not body or len(body.strip()) < 10:
        results.add_fail(f"Skill '{plugin_name}:{skill_name}' has content",
                        "Skill body is empty or too short")
    else:
        results.add_pass(f"Skill '{plugin_name}:{skill_name}' has content")


def test_plugins(marketplace_config: Dict, results: TestResult):
    """Test all plugins."""
    print(f"\n{BLUE}Testing Plugins{RESET}")
    print(f"{BLUE}{'─'*60}{RESET}")
    
    for plugin in marketplace_config.get('plugins', []):
        plugin_name = plugin.get('name', 'unknown')
        source = plugin.get('source', '')
        
        if not source:
            continue
            
        plugin_path = Path(source)
        if not plugin_path.exists():
            continue
            
        print(f"\n{BLUE}Plugin: {plugin_name}{RESET}")
        
        # Test manifest
        manifest = test_plugin_manifest(plugin_path, results)
        
        # Test commands
        commands_dir = plugin_path / 'commands'
        if commands_dir.exists():
            command_files = list(commands_dir.glob('*.md'))
            if command_files:
                print(f"\n  Commands ({len(command_files)}):")
                for cmd_file in command_files:
                    test_command_file(cmd_file, plugin_name, results)
            else:
                results.add_warning(f"Plugin '{plugin_name}' has commands",
                                  "No command files found")
        else:
            results.add_warning(f"Plugin '{plugin_name}' has commands directory",
                              "commands/ directory not found")
            
        # Test skills
        skills_dir = plugin_path / 'skills'
        if skills_dir.exists():
            skill_dirs = [d for d in skills_dir.iterdir() if d.is_dir()]
            if skill_dirs:
                print(f"\n  Skills ({len(skill_dirs)}):")
                for skill_dir in skill_dirs:
                    test_skill_file(skill_dir, plugin_name, results)
            else:
                results.add_warning(f"Plugin '{plugin_name}' has skills",
                                  "No skill directories found")


def main():
    """Run all tests."""
    print(f"{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}Lynyx Claude Marketplace Test Suite{RESET}")
    print(f"{BLUE}{'='*60}{RESET}")
    
    # Change to repo root
    repo_root = Path(__file__).parent
    os.chdir(repo_root)
    
    results = TestResult()
    
    # Test marketplace config
    marketplace_config = test_marketplace_config(results)
    
    # Test plugins
    if marketplace_config:
        test_plugins(marketplace_config, results)
    
    # Print summary
    success = results.print_summary()
    
    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())
