#!/bin/bash
# Installation simulation test for lynyx-claude marketplace
# This script validates that the marketplace and plugins can be properly installed

# Don't exit on error - we want to collect all test results
set +e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0
WARNINGS=0

# Functions
print_header() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

print_section() {
    echo -e "\n${BLUE}$1${NC}"
    echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
}

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    echo -e "  ${RED}Error: $2${NC}"
    ((FAILED++))
}

test_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    echo -e "  ${YELLOW}Warning: $2${NC}"
    ((WARNINGS++))
}

# Main tests
print_header "Lynyx Claude Installation Test Suite"

# Test 1: Repository structure
print_section "Testing Repository Structure"

if [ -d ".claude-plugin" ]; then
    test_pass "Repository has .claude-plugin directory"
else
    test_fail "Repository has .claude-plugin directory" "Directory not found"
fi

if [ -f ".claude-plugin/marketplace.json" ]; then
    test_pass "Marketplace configuration exists"
else
    test_fail "Marketplace configuration exists" "File not found"
fi

if [ -d "plugins" ]; then
    test_pass "Plugins directory exists"
else
    test_fail "Plugins directory exists" "Directory not found"
fi

# Test 2: JSON validation
print_section "Testing JSON Files"

if command -v python3 &> /dev/null; then
    if python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))" 2>/dev/null; then
        test_pass "marketplace.json is valid JSON"
    else
        test_fail "marketplace.json is valid JSON" "Invalid JSON format"
    fi
    
    # Test each plugin manifest
    for plugin_dir in plugins/*; do
        if [ -d "$plugin_dir" ]; then
            plugin_name=$(basename "$plugin_dir")
            manifest="$plugin_dir/.claude-plugin/plugin.json"
            
            if [ -f "$manifest" ]; then
                if python3 -c "import json; json.load(open('$manifest'))" 2>/dev/null; then
                    test_pass "Plugin '$plugin_name' manifest is valid JSON"
                else
                    test_fail "Plugin '$plugin_name' manifest is valid JSON" "Invalid JSON format"
                fi
            else
                test_fail "Plugin '$plugin_name' has manifest" "plugin.json not found"
            fi
        fi
    done
else
    test_warning "JSON validation" "Python3 not available for JSON validation"
fi

# Test 3: Plugin structure
print_section "Testing Plugin Structure"

for plugin_dir in plugins/*; do
    if [ -d "$plugin_dir" ]; then
        plugin_name=$(basename "$plugin_dir")
        
        # Check for .claude-plugin directory
        if [ -d "$plugin_dir/.claude-plugin" ]; then
            test_pass "Plugin '$plugin_name' has .claude-plugin directory"
        else
            test_fail "Plugin '$plugin_name' has .claude-plugin directory" "Directory not found"
        fi
        
        # Check for plugin.json
        if [ -f "$plugin_dir/.claude-plugin/plugin.json" ]; then
            test_pass "Plugin '$plugin_name' has plugin.json"
        else
            test_fail "Plugin '$plugin_name' has plugin.json" "File not found"
        fi
        
        # Check for commands or skills
        has_commands=false
        has_skills=false
        
        if [ -d "$plugin_dir/commands" ] && [ -n "$(ls -A $plugin_dir/commands/*.md 2>/dev/null)" ]; then
            has_commands=true
            cmd_count=$(ls -1 "$plugin_dir/commands"/*.md 2>/dev/null | wc -l)
            test_pass "Plugin '$plugin_name' has $cmd_count command(s)"
        fi
        
        if [ -d "$plugin_dir/skills" ] && [ -n "$(ls -A $plugin_dir/skills 2>/dev/null)" ]; then
            has_skills=true
            skill_count=$(ls -1d "$plugin_dir/skills"/*/ 2>/dev/null | wc -l)
            test_pass "Plugin '$plugin_name' has $skill_count skill(s)"
        fi
        
        if [ "$has_commands" = false ] && [ "$has_skills" = false ]; then
            test_warning "Plugin '$plugin_name' has commands or skills" "No commands or skills found"
        fi
    fi
done

# Test 4: Command files
print_section "Testing Command Files"

for cmd_file in plugins/*/commands/*.md; do
    if [ -f "$cmd_file" ]; then
        plugin_name=$(echo "$cmd_file" | cut -d'/' -f2)
        cmd_name=$(basename "$cmd_file" .md)
        
        # Check if file has YAML frontmatter starting at the first line
        if awk 'BEGIN{found=0} NR==1{if($0!="---") exit 1} NR>1 && $0=="---"{found=1; exit 0} END{exit !found}' "$cmd_file"; then
            test_pass "Command '$plugin_name:$cmd_name' has YAML frontmatter"

            # Check if it has description within frontmatter
            if awk 'BEGIN{has_desc=0} NR==1{if($0!="---") exit 1} /^description:/{has_desc=1} NR>1 && $0=="---"{exit !has_desc}' "$cmd_file"; then
                test_pass "Command '$plugin_name:$cmd_name' has description"
            else
                test_fail "Command '$plugin_name:$cmd_name' has description" "Missing description field"
            fi
        else
            test_fail "Command '$plugin_name:$cmd_name' has YAML frontmatter" "Missing frontmatter"
        fi
        
        # Check if file has content after frontmatter
        # Count lines after the closing --- of frontmatter
        content_lines=$(awk 'NR==1{if($0!="---") exit} /^---[[:space:]]*$/{if(++count==2) flag=1; next} flag' "$cmd_file" | grep -c .)
        if [ "$content_lines" -gt 5 ]; then
            test_pass "Command '$plugin_name:$cmd_name' has sufficient content"
        else
            test_fail "Command '$plugin_name:$cmd_name' has sufficient content" "Content too short"
        fi
    fi
done

# Test 5: Skill files
print_section "Testing Skill Files"

for skill_dir in plugins/*/skills/*/; do
    if [ -d "$skill_dir" ]; then
        plugin_name=$(echo "$skill_dir" | cut -d'/' -f2)
        skill_name=$(basename "$skill_dir")
        
        # Check for SKILL.md
        if [ -f "$skill_dir/SKILL.md" ]; then
            test_pass "Skill '$plugin_name:$skill_name' has SKILL.md"
            
            # Check for YAML frontmatter starting at the first line
            if awk 'BEGIN{found=0} NR==1{if($0!="---") exit 1} NR>1 && $0=="---"{found=1; exit 0} END{exit !found}' "$skill_dir/SKILL.md"; then
                test_pass "Skill '$plugin_name:$skill_name' has YAML frontmatter"

                # Check for description within frontmatter
                if awk 'BEGIN{has_desc=0} NR==1{if($0!="---") exit 1} /^description:/{has_desc=1} NR>1 && $0=="---"{exit !has_desc}' "$skill_dir/SKILL.md"; then
                    test_pass "Skill '$plugin_name:$skill_name' has description"
                else
                    test_fail "Skill '$plugin_name:$skill_name' has description" "Missing description field"
                fi
            else
                test_fail "Skill '$plugin_name:$skill_name' has YAML frontmatter" "Missing frontmatter"
            fi
        else
            test_fail "Skill '$plugin_name:$skill_name' has SKILL.md" "File not found"
        fi
    fi
done

# Test 6: Documentation
print_section "Testing Documentation"

if [ -f "README.md" ]; then
    test_pass "Repository has README.md"
    
    # Check for installation instructions
    if grep -q "marketplace add" "README.md"; then
        test_pass "README has marketplace installation instructions"
    else
        test_warning "README has marketplace installation instructions" "Installation section may be missing"
    fi
    
    # Check for plugin listing
    if grep -q "Available Plugins" "README.md"; then
        test_pass "README lists available plugins"
    else
        test_warning "README lists available plugins" "Plugin listing may be missing"
    fi
else
    test_fail "Repository has README.md" "File not found"
fi

# Test 7: Installation commands
print_section "Testing Installation Commands"

# Extract installation commands from README
if [ -f "README.md" ]; then
    # GitHub repository method
    if grep -q "marketplace add EnzanNoMetsuke/lynyx-claude" "README.md"; then
        test_pass "README includes GitHub repository installation method"
    else
        test_warning "README includes GitHub repository installation method" "Command not found in README"
    fi
    
    # Git URL method
    if grep -q "marketplace add https://github.com" "README.md"; then
        test_pass "README includes Git URL installation method"
    else
        test_warning "README includes Git URL installation method" "Command not found in README"
    fi
    
    # Local path method
    if grep -q "marketplace add /path/to" "README.md"; then
        test_pass "README includes local path installation method"
    else
        test_warning "README includes local path installation method" "Command not found in README"
    fi
    
    # Plugin installation commands
    if grep -q "plugin install.*@lynyx-claude" "README.md"; then
        test_pass "README includes plugin installation commands"
    else
        test_warning "README includes plugin installation commands" "Commands not found in README"
    fi
fi

# Test 8: Version consistency
print_section "Testing Version Consistency"

if [ -f ".claude-plugin/marketplace.json" ] && command -v python3 &> /dev/null; then
    marketplace_version=$(python3 -c "import json; print(json.load(open('.claude-plugin/marketplace.json'))['version'])" 2>/dev/null)
    
    if [ -n "$marketplace_version" ]; then
        test_pass "Marketplace version is defined: $marketplace_version"
        
        # Check if plugins in marketplace have version specified
        plugin_count=$(python3 -c "import json; print(len(json.load(open('.claude-plugin/marketplace.json'))['plugins']))" 2>/dev/null)
        
        for i in $(seq 0 $((plugin_count - 1))); do
            plugin_name=$(python3 -c "import json; print(json.load(open('.claude-plugin/marketplace.json'))['plugins'][$i]['name'])" 2>/dev/null)
            marketplace_plugin_version=$(python3 -c "import json; d=json.load(open('.claude-plugin/marketplace.json'))['plugins'][$i]; print(d.get('version', 'none'))" 2>/dev/null)
            manifest_version=$(python3 -c "import json; print(json.load(open('plugins/$plugin_name/.claude-plugin/plugin.json'))['version'])" 2>/dev/null)
            
            if [ "$marketplace_plugin_version" = "none" ]; then
                test_warning "Plugin '$plugin_name' version in marketplace" "No version specified in marketplace"
            elif [ "$marketplace_plugin_version" = "$manifest_version" ]; then
                test_pass "Plugin '$plugin_name' versions match: $manifest_version"
            else
                test_fail "Plugin '$plugin_name' versions match" "Marketplace has $marketplace_plugin_version, manifest has $manifest_version"
            fi
        done
    fi
fi

# Print summary
print_header "Test Summary"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All critical tests passed!${NC}"
    echo -e "${GREEN}The marketplace is ready for installation in Claude Code.${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed. Please fix the issues before using the marketplace.${NC}"
    exit 1
fi
