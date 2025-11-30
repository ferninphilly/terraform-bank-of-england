#!/bin/bash
# verify_auth.sh - Verifies Terraform Azure authentication
#
# This script checks that all required environment variables are set
# and verifies Azure CLI and Terraform authentication.
#
# Usage: ./verify_auth.sh

echo "=========================================="
echo "Terraform Azure Authentication Verification"
echo "=========================================="
echo ""

# Track if all checks pass
ALL_CHECKS_PASS=true

# Check if variables are set
echo "Checking environment variables..."

if [ -z "$ARM_CLIENT_ID" ]; then
    echo "✗ ARM_CLIENT_ID is not set"
    ALL_CHECKS_PASS=false
else
    echo "✓ ARM_CLIENT_ID is set (${ARM_CLIENT_ID:0:8}...)"
fi

if [ -z "$ARM_CLIENT_SECRET" ]; then
    echo "✗ ARM_CLIENT_SECRET is not set"
    ALL_CHECKS_PASS=false
else
    echo "✓ ARM_CLIENT_SECRET is set"
fi

if [ -z "$ARM_TENANT_ID" ]; then
    echo "✗ ARM_TENANT_ID is not set"
    ALL_CHECKS_PASS=false
else
    echo "✓ ARM_TENANT_ID is set ($ARM_TENANT_ID)"
fi

if [ -z "$ARM_SUBSCRIPTION_ID" ]; then
    echo "✗ ARM_SUBSCRIPTION_ID is not set"
    ALL_CHECKS_PASS=false
else
    echo "✓ ARM_SUBSCRIPTION_ID is set ($ARM_SUBSCRIPTION_ID)"
fi

echo ""

# Test Azure CLI authentication
echo "Testing Azure CLI authentication..."
if command -v az &> /dev/null; then
    az account show > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ Azure CLI is authenticated"
        echo ""
        echo "Current subscription:"
        az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId}" -o table
    else
        echo "✗ Azure CLI is not authenticated. Run 'az login'"
        ALL_CHECKS_PASS=false
    fi
else
    echo "✗ Azure CLI is not installed or not in PATH"
    ALL_CHECKS_PASS=false
fi

echo ""

# Test Terraform
if command -v terraform &> /dev/null; then
    echo "Testing Terraform installation..."
    terraform version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version' 2>/dev/null || terraform version | head -n 1)
        echo "✓ Terraform is installed: $TERRAFORM_VERSION"
        echo ""
        echo "To test Azure authentication with Terraform:"
        echo "  1. Create a test terraform file (e.g., test.tf)"
        echo "  2. Run: terraform init"
        echo "  3. Run: terraform plan"
    else
        echo "✗ Terraform is installed but not working properly"
        ALL_CHECKS_PASS=false
    fi
else
    echo "ℹ Terraform is not installed"
    echo "  Install Terraform to test Azure provider authentication"
fi

echo ""
echo "=========================================="

if [ "$ALL_CHECKS_PASS" = true ]; then
    echo "✓ All checks passed! You're ready to use Terraform with Azure."
    exit 0
else
    echo "✗ Some checks failed. Please review the errors above."
    echo ""
    echo "To set environment variables, run:"
    echo "  source ./set_vars.sh"
    exit 1
fi

