#!/bin/bash

# Script to publish VM module to GitHub
# This script automates the process of publishing the module to GitHub

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Publish Terraform Module to GitHub"
echo "=========================================="
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}✗${NC} GitHub CLI (gh) not found"
    echo "   Install it first: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}✗${NC} Not authenticated with GitHub"
    echo "   Run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓${NC} GitHub CLI installed and authenticated"
echo ""

# Get GitHub username
GITHUB_USER=$(gh api user -q .login)
echo "GitHub Username: $GITHUB_USER"
echo ""

# Module directory
MODULE_DIR="modules/vm"
REPO_NAME="terraform-azurerm-vm"

# Check if module directory exists
if [ ! -d "$MODULE_DIR" ]; then
    echo -e "${RED}✗${NC} Module directory not found: $MODULE_DIR"
    exit 1
fi

echo "Module directory: $MODULE_DIR"
echo ""

# Navigate to module directory
cd "$MODULE_DIR"

# Check if already a git repository
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠${NC} Already a Git repository"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    # Initialize Git repository
    echo "Initializing Git repository..."
    git init
    echo -e "${GREEN}✓${NC} Git repository initialized"
fi

# Add files
echo ""
echo "Adding files..."
git add .
echo -e "${GREEN}✓${NC} Files added"

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠${NC} No changes to commit"
else
    # Commit
    echo ""
    echo "Creating commit..."
    git commit -m "Initial commit: Azure VM module with networking"
    echo -e "${GREEN}✓${NC} Changes committed"
fi

# Check if remote exists
if git remote | grep -q "^origin$"; then
    echo -e "${YELLOW}⚠${NC} Remote 'origin' already exists"
    REMOTE_URL=$(git remote get-url origin)
    echo "   Current remote: $REMOTE_URL"
    read -p "Update remote? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote set-url origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
        echo -e "${GREEN}✓${NC} Remote updated"
    fi
else
    # Create GitHub repository
    echo ""
    echo "Creating GitHub repository..."
    if gh repo view "$GITHUB_USER/$REPO_NAME" &> /dev/null; then
        echo -e "${YELLOW}⚠${NC} Repository already exists: $GITHUB_USER/$REPO_NAME"
        read -p "Continue with existing repository? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        gh repo create "$REPO_NAME" \
            --public \
            --description "Terraform module for Azure Linux VM with networking" \
            --clone=false
        echo -e "${GREEN}✓${NC} Repository created: $GITHUB_USER/$REPO_NAME"
    fi
    
    # Add remote
    echo ""
    echo "Adding remote..."
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo -e "${GREEN}✓${NC} Remote added"
fi

# Push to GitHub
echo ""
echo "Pushing to GitHub..."
git branch -M main
git push -u origin main
echo -e "${GREEN}✓${NC} Pushed to GitHub"

# Create version tag
echo ""
read -p "Create version tag v1.0.0? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Creating tag v1.0.0..."
    git tag -a v1.0.0 -m "Initial release: VM module with networking"
    git push origin v1.0.0
    echo -e "${GREEN}✓${NC} Tag v1.0.0 created and pushed"
    
    # Create release
    echo ""
    read -p "Create GitHub release? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating release..."
        gh release create v1.0.0 \
            --title "v1.0.0 - Initial Release" \
            --notes "Initial release of Azure VM module with networking infrastructure.

Features:
- Virtual Network and Subnet
- Public IP Address
- Network Security Group
- Network Interface
- Linux Virtual Machine

See README.md for usage examples."
        echo -e "${GREEN}✓${NC} Release created"
    fi
fi

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "${GREEN}✓${NC} Module published to GitHub"
echo "   Repository: https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "Next steps:"
echo "  1. Use module in Terraform:"
echo "     source = \"github.com/$GITHUB_USER/$REPO_NAME?ref=v1.0.0\""
echo "  2. See example-usage/ directory for example"
echo ""

