#!/usr/bin/env bash
#
# Auto-Coder Continuation Script
# ==============================
# Automatically continues coding sessions until project completion.
#
# Usage:
#   ./continue.sh           # Default 3-second delay between sessions
#   ./continue.sh 5         # Custom 5-second delay
#   ./continue.sh 0         # No delay (immediate continuation)
#
# Stop with Ctrl+C at any time. Progress is automatically saved.
#

set -e

# Configuration
DELAY=${1:-3}
MAX_FAILURES=3
FAILURE_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "                      AUTO-CODER CONTINUOUS MODE"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo -e "${NC}"
echo "Delay between sessions: ${DELAY}s"
echo "Stop with Ctrl+C (progress is saved automatically)"
echo ""

# Trap Ctrl+C for graceful exit
trap 'echo -e "\n${YELLOW}Stopping auto-coder...${NC}"; exit 0' INT

# Main loop
SESSION=1
while true; do
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Starting session ${SESSION}...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Run coding session
    if claude -p "/lynyx-agent-kit:auto-coder code"; then
        # Session completed successfully
        FAILURE_COUNT=0
        echo ""
        echo -e "${GREEN}Session ${SESSION} completed successfully.${NC}"
    else
        # Session failed or was interrupted
        EXIT_CODE=$?
        FAILURE_COUNT=$((FAILURE_COUNT + 1))

        if [ $EXIT_CODE -eq 130 ]; then
            # Ctrl+C was pressed
            echo -e "\n${YELLOW}Session interrupted by user.${NC}"
            exit 0
        fi

        echo -e "${RED}Session ${SESSION} exited with code ${EXIT_CODE}.${NC}"

        if [ $FAILURE_COUNT -ge $MAX_FAILURES ]; then
            echo -e "${RED}Maximum consecutive failures (${MAX_FAILURES}) reached. Stopping.${NC}"
            echo "Check .auto-coder/progress.md for details."
            exit 1
        fi

        echo -e "${YELLOW}Failures: ${FAILURE_COUNT}/${MAX_FAILURES}. Retrying...${NC}"
    fi

    # Check if project is complete by looking for completion marker in output
    # (This is a heuristic - the actual check happens inside Claude)

    SESSION=$((SESSION + 1))

    # Delay before next session
    if [ "$DELAY" -gt 0 ]; then
        echo ""
        echo -e "${BLUE}Waiting ${DELAY} seconds before next session...${NC}"
        echo "(Press Ctrl+C to stop)"
        sleep "$DELAY"
    fi

    echo ""
done
