#!/bin/bash
# Master test runner for lynyx-claude marketplace
# Runs all test suites and provides a comprehensive report

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Change to script directory
cd "$(dirname "$0")"

print_banner() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${BLUE}Lynyx Claude Marketplace - Test Suite Runner${NC}           ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_test_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Track overall results
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Main
print_banner

# Test 1: Python validation suite
print_test_header "Test Suite 1: Python Marketplace Validator"
if [ -f "test_marketplace.py" ]; then
    ((TOTAL_SUITES++))
    if python3 test_marketplace.py; then
        echo -e "\n${GREEN}✓ Python validation suite PASSED${NC}"
        ((PASSED_SUITES++))
    else
        echo -e "\n${RED}✗ Python validation suite FAILED${NC}"
        ((FAILED_SUITES++))
    fi
else
    echo -e "${YELLOW}⚠ test_marketplace.py not found${NC}"
fi

# Test 2: Bash installation suite
print_test_header "Test Suite 2: Installation Validator"
if [ -f "test_installation.sh" ]; then
    ((TOTAL_SUITES++))
    if bash test_installation.sh; then
        echo -e "\n${GREEN}✓ Installation validation suite PASSED${NC}"
        ((PASSED_SUITES++))
    else
        echo -e "\n${RED}✗ Installation validation suite FAILED${NC}"
        ((FAILED_SUITES++))
    fi
else
    echo -e "${YELLOW}⚠ test_installation.sh not found${NC}"
fi

# Final summary
echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${BLUE}Final Test Summary${NC}                                      ${CYAN}║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC}  Total Suites:  ${BLUE}$TOTAL_SUITES${NC}                                        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Passed:        ${GREEN}$PASSED_SUITES${NC}                                        ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}  Failed:        ${RED}$FAILED_SUITES${NC}                                        ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"

if [ $FAILED_SUITES -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All test suites passed!${NC}"
    echo -e "${GREEN}The marketplace is validated and ready for use.${NC}\n"
    exit 0
else
    echo -e "\n${RED}❌ Some test suites failed.${NC}"
    echo -e "${RED}Please review the errors above.${NC}\n"
    exit 1
fi
