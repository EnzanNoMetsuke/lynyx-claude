#!/usr/bin/env python3
"""
Auto-Coder File Locator Script
==============================
Locates skill files for the lynyx-agent-kit plugin in the Claude plugin cache.

This script helps agents running the auto-coder skill find the skill's instruction
files (CODER.md, INITIALIZER.md, etc.) in a deterministic manner.

Usage:
    python skill-file-locator.py [skill_name]

    skill_name: Name of the skill to locate (default: auto-coder)

Output:
    Tree view of the skill's files with full paths, for example:

    ~/.claude/plugins/cache/lynyx-claude/lynyx-agent-kit/1.2.1/skills/auto-coder
    ├── scripts
    │   └── continue.sh
    ├── CODER.md
    ├── FEATURE_SCHEMA.md
    ├── INITIALIZER.md
    └── SKILL.md
"""

import sys
from pathlib import Path


def parse_version(version_str: str) -> tuple[int, int, int, bool] | None:
    """
    Parse a semver version string into a comparable tuple.
    
    Args:
        version_str: Version string like "1.2.3" or "1.2.3-beta.1"
    
    Returns:
        Tuple of (major, minor, patch, is_stable) where is_stable is True for
        release versions and False for prereleases. Returns None if invalid.
        
    Note:
        According to semver, prereleases have lower precedence than the release
        version (1.2.3 > 1.2.3-beta.1). The is_stable flag ensures stable releases
        are preferred over prereleases with the same base version.
    """
    try:
        # Check if this is a prerelease (contains '-' before any '+')
        has_prerelease = '-' in version_str.split('+')[0]
        
        # Strip any prerelease/build metadata for base version comparison
        base_version = version_str.split('-')[0].split('+')[0]
        parts = base_version.split('.')
        if len(parts) >= 3:
            return (int(parts[0]), int(parts[1]), int(parts[2]), not has_prerelease)
        elif len(parts) == 2:
            return (int(parts[0]), int(parts[1]), 0, not has_prerelease)
        elif len(parts) == 1:
            return (int(parts[0]), 0, 0, not has_prerelease)
    except (ValueError, IndexError):
        pass
    return None


def get_latest_version(cache_dir: Path) -> str | None:
    """
    Find the latest version directory in the cache.
    
    Args:
        cache_dir: Path to the plugin cache directory
    
    Returns:
        The latest version string, or None if no valid versions found
    """
    if not cache_dir.exists():
        return None
    
    versions = []
    for item in cache_dir.iterdir():
        if item.is_dir():
            parsed = parse_version(item.name)
            if parsed is not None:
                versions.append((parsed, item.name))
    
    if not versions:
        return None
    
    # Sort by parsed version tuple (descending) and return the latest
    versions.sort(key=lambda x: x[0], reverse=True)
    return versions[0][1]


def build_tree(directory: Path, prefix: str = "", is_last: bool = True) -> list[str]:
    """
    Build a tree view of a directory structure.
    
    Args:
        directory: Path to the directory
        prefix: Current line prefix for indentation
        is_last: Whether this is the last item in the parent directory
    
    Returns:
        List of strings representing the tree view lines
    """
    lines = []
    
    # Get all items in directory, sorted (directories first, then files)
    try:
        items = sorted(directory.iterdir(), key=lambda x: (not x.is_dir(), x.name))
    except PermissionError:
        return lines
    
    for idx, item in enumerate(items):
        is_last_item = idx == len(items) - 1
        
        # Choose the appropriate connector
        connector = "└── " if is_last_item else "├── "
        lines.append(f"{prefix}{connector}{item.name}")
        
        # If it's a directory, recurse
        if item.is_dir():
            # Choose the appropriate extension for child items
            extension = "    " if is_last_item else "│   "
            child_lines = build_tree(item, prefix + extension, is_last_item)
            lines.extend(child_lines)
    
    return lines


def locate_skill_files(skill_name: str = "auto-coder") -> int:
    """
    Locate and display skill files for the lynyx-agent-kit plugin.
    
    Args:
        skill_name: Name of the skill to locate
    
    Returns:
        Exit code (0 for success, 1 for error)
    """
    # Determine the cache directory path
    home = Path.home()
    cache_dir = home / ".claude" / "plugins" / "cache" / "lynyx-claude" / "lynyx-agent-kit"
    
    # Check if the plugin cache exists
    if not cache_dir.exists():
        print(f"ERROR: Plugin cache not found at {cache_dir}", file=sys.stderr)
        print("\nThe lynyx-agent-kit plugin may not be installed.", file=sys.stderr)
        print("Install it by adding the marketplace to Claude Code.", file=sys.stderr)
        return 1
    
    # Find the latest version
    latest_version = get_latest_version(cache_dir)
    if latest_version is None:
        print(f"ERROR: No valid version directories found in {cache_dir}", file=sys.stderr)
        return 1
    
    # Construct path to the skill directory
    version_dir = cache_dir / latest_version
    skill_dir = version_dir / "skills" / skill_name
    
    # Check if the skill directory exists
    if not skill_dir.exists():
        print(f"ERROR: Skill directory not found at {skill_dir}", file=sys.stderr)
        print(f"\nAvailable skills in {version_dir / 'skills'}:", file=sys.stderr)
        skills_dir = version_dir / "skills"
        if skills_dir.exists():
            for item in skills_dir.iterdir():
                if item.is_dir():
                    print(f"  - {item.name}", file=sys.stderr)
        return 1
    
    # Output the tree view with ~ shorthand for home directory
    skill_dir_display = str(skill_dir).replace(str(home), "~")
    print(skill_dir_display)
    tree_lines = build_tree(skill_dir)
    for line in tree_lines:
        print(line)
    
    return 0


def main():
    """Main entry point."""
    # Parse command line arguments
    skill_name = "auto-coder"
    if len(sys.argv) > 1:
        skill_name = sys.argv[1]
    
    return locate_skill_files(skill_name)


if __name__ == "__main__":
    sys.exit(main())
