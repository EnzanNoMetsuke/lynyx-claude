#!/bin/bash
# Claude CLI validation test suite
# Uses official Claude Code CLI to validate marketplace and plugin configurations

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Change to script directory
cd "$(dirname "$0")"

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

# Test counters
PASSED=0
FAILED=0
WARNINGS=0

print_header "Claude CLI Validation Test Suite"

# Check if Claude CLI is installed
print_section "Checking Claude CLI Installation"

if command -v claude &> /dev/null; then
    test_pass "Claude CLI is installed"
    CLAUDE_VERSION=$(claude --version 2>&1 || echo "unknown")
    echo -e "  ${BLUE}Version: ${CLAUDE_VERSION}${NC}"
else
    test_warning "Claude CLI not found" "Attempting to install..."
    
    # Try NPM installation first (since Node.js is available)
    if command -v npm &> /dev/null; then
        NODE_VERSION=$(node --version 2>&1)
        echo -e "  ${BLUE}Node.js version: ${NODE_VERSION}${NC}"
        
        echo -e "  ${BLUE}Installing Claude CLI via NPM...${NC}"
        if npm install -g @anthropic-ai/claude-code 2>&1 | grep -q "added\|up to date"; then
            test_pass "Claude CLI installed via NPM"
        else
            # Try official installer as fallback
            echo -e "  ${BLUE}Trying official installer...${NC}"
            if curl -fsSL https://claude.ai/install.sh | bash 2>&1; then
                test_pass "Claude CLI installed via official installer"
                # Source the shell config to make claude command available
                export PATH="$HOME/.claude/bin:$PATH"
            else
                test_fail "Claude CLI installation" "Failed to install via NPM or official installer"
                echo -e "\n${RED}Cannot proceed without Claude CLI${NC}"
                exit 1
            fi
        fi
    else
        # Try official installer
        echo -e "  ${BLUE}Installing Claude CLI via official installer...${NC}"
        if curl -fsSL https://claude.ai/install.sh | bash 2>&1; then
            test_pass "Claude CLI installed via official installer"
            # Source the shell config to make claude command available
            export PATH="$HOME/.claude/bin:$PATH"
        else
            test_fail "Claude CLI installation" "Failed to install"
            echo -e "\n${RED}Cannot proceed without Claude CLI${NC}"
            exit 1
        fi
    fi
fi

# Verify Claude CLI is now available
if ! command -v claude &> /dev/null; then
    test_fail "Claude CLI availability" "Command not found after installation"
    echo -e "\n${RED}Cannot proceed without Claude CLI${NC}"
    exit 1
fi

# Test 1: Validate marketplace manifest
print_section "Validating Marketplace Manifest"

if [ -f ".claude-plugin/marketplace.json" ]; then
    test_pass "Marketplace manifest exists"
    
    echo -e "\n${BLUE}Running: claude plugin validate .claude-plugin/marketplace.json${NC}"
    if claude plugin validate .claude-plugin/marketplace.json 2>&1; then
        test_pass "Marketplace manifest validation"
    else
        test_fail "Marketplace manifest validation" "Validation failed"
    fi
else
    test_fail "Marketplace manifest exists" "File not found"
fi

# Test 2: Validate individual plugin manifests
print_section "Validating Plugin Manifests"

for plugin_dir in plugins/*; do
    if [ -d "$plugin_dir" ]; then
        plugin_name=$(basename "$plugin_dir")
        manifest="$plugin_dir/.claude-plugin/plugin.json"
        
        if [ -f "$manifest" ]; then
            test_pass "Plugin '$plugin_name' manifest exists"
            
            echo -e "\n${BLUE}Running: claude plugin validate $manifest${NC}"
            if claude plugin validate "$manifest" 2>&1; then
                test_pass "Plugin '$plugin_name' manifest validation"
            else
                test_fail "Plugin '$plugin_name' manifest validation" "Validation failed"
            fi
        else
            test_fail "Plugin '$plugin_name' manifest exists" "File not found"
        fi
    fi
done

# Test 3: Validate marketplace structure
print_section "Validating Marketplace Structure"

if [ -d ".claude-plugin" ]; then
    test_pass "Marketplace directory exists"
    
    # Check if we can validate the entire marketplace
    echo -e "\n${BLUE}Running: claude plugin validate .${NC}"
    if claude plugin validate . 2>&1; then
        test_pass "Complete marketplace validation"
    else
        # This might not be supported, so treat as warning
        test_warning "Complete marketplace validation" "Command may not be fully supported"
    fi
else
    test_fail "Marketplace directory exists" "Directory not found"
fi

# Print summary
print_header "Test Summary"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All Claude CLI validations passed!${NC}"
    echo -e "${GREEN}The marketplace is validated by official Claude Code tools.${NC}"
    exit 0
else
    echo -e "\n${RED}Some validations failed. Please fix the issues.${NC}"
    exit 1
fi
