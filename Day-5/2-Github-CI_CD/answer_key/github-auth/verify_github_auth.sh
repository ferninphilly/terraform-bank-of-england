#!/bin/bash

# GitHub Authentication Verification Script
# This script verifies that GitHub authentication is properly configured

set -e

echo "=========================================="
echo "GitHub Authentication Verification"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gh CLI is installed
echo "1. Checking GitHub CLI installation..."
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -n 1)
    echo -e "${GREEN}✓${NC} GitHub CLI installed: $GH_VERSION"
else
    echo -e "${RED}✗${NC} GitHub CLI not found. Please install it first."
    echo "   See: github_authentication_linux_review.md"
    exit 1
fi
echo ""

# Check authentication status
echo "2. Checking GitHub authentication status..."
if gh auth status &> /dev/null; then
    AUTH_STATUS=$(gh auth status 2>&1 | grep "Logged in" || echo "")
    if [ -n "$AUTH_STATUS" ]; then
        echo -e "${GREEN}✓${NC} Authenticated with GitHub"
        echo "   $AUTH_STATUS"
    else
        echo -e "${YELLOW}⚠${NC} Authentication status unclear"
    fi
else
    echo -e "${RED}✗${NC} Not authenticated with GitHub"
    echo "   Run: gh auth login"
    exit 1
fi
echo ""

# Test GitHub API access
echo "3. Testing GitHub API access..."
if gh api user &> /dev/null; then
    USERNAME=$(gh api user -q .login)
    echo -e "${GREEN}✓${NC} API access working"
    echo "   Logged in as: $USERNAME"
else
    echo -e "${RED}✗${NC} Cannot access GitHub API"
    echo "   Check your authentication"
    exit 1
fi
echo ""

# Check Git configuration
echo "4. Checking Git configuration..."
GIT_USER=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$GIT_USER" ] && [ -n "$GIT_EMAIL" ]; then
    echo -e "${GREEN}✓${NC} Git configured"
    echo "   User: $GIT_USER"
    echo "   Email: $GIT_EMAIL"
else
    echo -e "${YELLOW}⚠${NC} Git user information not configured"
    echo "   Run: git config --global user.name 'Your Name'"
    echo "   Run: git config --global user.email 'your.email@example.com'"
fi
echo ""

# Check Git credential helper
echo "5. Checking Git credential helper..."
CREDENTIAL_HELPER=$(git config --global credential.helper 2>/dev/null || echo "")
if [ -n "$CREDENTIAL_HELPER" ]; then
    echo -e "${GREEN}✓${NC} Git credential helper configured: $CREDENTIAL_HELPER"
else
    echo -e "${YELLOW}⚠${NC} Git credential helper not configured"
    echo "   Run: gh auth setup-git"
fi
echo ""

# Check SSH keys (if SSH is being used)
echo "6. Checking SSH configuration..."
if [ -f ~/.ssh/id_ed25519 ] || [ -f ~/.ssh/id_rsa ]; then
    echo -e "${GREEN}✓${NC} SSH keys found"
    
    # Test SSH connection
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo -e "${GREEN}✓${NC} SSH authentication working"
    else
        echo -e "${YELLOW}⚠${NC} SSH keys exist but GitHub connection not tested"
        echo "   Run: ssh -T git@github.com"
    fi
else
    echo -e "${YELLOW}⚠${NC} No SSH keys found (optional)"
    echo "   SSH keys are recommended for secure Git operations"
fi
echo ""

# Summary
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "${GREEN}✓${NC} GitHub CLI installed and authenticated"
echo -e "${GREEN}✓${NC} GitHub API access working"
if [ -n "$GIT_USER" ] && [ -n "$GIT_EMAIL" ]; then
    echo -e "${GREEN}✓${NC} Git configured"
else
    echo -e "${YELLOW}⚠${NC} Git user information needs configuration"
fi
echo ""
echo "You're ready to work with GitHub!"
echo "Next steps:"
echo "  1. Clone a repository: gh repo clone username/repo"
echo "  2. Create a repository: gh repo create"
echo "  3. Set up GitHub Actions workflows"
echo ""

