#!/bin/bash
set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get commit message and deployment decision from smart-commit.py
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT=$(python "$SCRIPT_DIR/smart-commit.py" 2>&1)

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed: Could not generate commit message${NC}"
    exit 1
fi

# Parse output
MESSAGE=$(echo "$OUTPUT" | head -n 1)
DEPLOY_LINE=$(echo "$OUTPUT" | grep "DEPLOY_NEEDED" || echo "DEPLOY_NEEDED=false")
DEPLOY_NEEDED=$(echo "$DEPLOY_LINE" | cut -d= -f2)

# Stage and commit silently
if ! git add . >/dev/null 2>&1 || ! git commit -m "$MESSAGE" >/dev/null 2>&1; then
    echo -e "${RED}❌ Failed: Could not commit changes${NC}"
    exit 1
fi

# Get commit hash
COMMIT_HASH=$(git rev-parse --short HEAD)

# Push to GitHub silently
if ! git push origin master >/dev/null 2>&1; then
    echo -e "${RED}❌ Failed: Could not push to GitHub${NC}"
    exit 1
fi

# Deploy if needed
if [ "$DEPLOY_NEEDED" = "true" ]; then
    # Run deployment in background with output redirected
    if bash deploy_automated.sh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Success:${NC} $MESSAGE ($COMMIT_HASH) → Deployed"
    else
        echo -e "${RED}❌ Failed:${NC} Committed ($COMMIT_HASH) but deployment failed"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Success:${NC} $MESSAGE ($COMMIT_HASH)"
fi
