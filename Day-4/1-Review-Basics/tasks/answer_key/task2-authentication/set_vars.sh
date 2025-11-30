#!/bin/bash
# set_vars.sh - Sets Terraform Azure authentication environment variables
# 
# This script reads Service Principal credentials from sp_output.json and
# sets the required environment variables for Terraform Azure provider authentication.
#
# Usage: source ./set_vars.sh
#        OR
#        . ./set_vars.sh

# Check if sp_output.json exists
if [ ! -f "sp_output.json" ]; then
    echo "Error: 'sp_output.json' not found."
    echo "Please ensure you have created a Service Principal and saved the output to sp_output.json"
    echo ""
    echo "To create a Service Principal, run:"
    echo "  az ad sp create-for-rbac --role=\"Contributor\" \\"
    echo "    --scopes=\"/subscriptions/\$(az account show --query id -o tsv)\" \\"
    echo "    --name \"http://terraform-service-principal\" > sp_output.json"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed."
    echo "Install it with:"
    echo "  sudo apt-get install jq      (Ubuntu/Debian)"
    echo "  sudo yum install jq          (RHEL/CentOS)"
    echo ""
    echo "Alternatively, you can manually extract values from sp_output.json"
    exit 1
fi

# Check if Azure CLI is authenticated
if ! az account show > /dev/null 2>&1; then
    echo "Warning: Azure CLI is not authenticated."
    echo "Run 'az login' first to authenticate."
    echo ""
fi

echo "Reading credentials from sp_output.json..."

# Extract values from JSON and set as environment variables
export ARM_CLIENT_ID=$(jq -r '.appId' sp_output.json)
export ARM_CLIENT_SECRET=$(jq -r '.password' sp_output.json)
export ARM_TENANT_ID=$(jq -r '.tenant' sp_output.json)

# Get subscription ID from Azure CLI
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Verify variables are set
if [ -z "$ARM_CLIENT_ID" ] || [ -z "$ARM_CLIENT_SECRET" ] || [ -z "$ARM_TENANT_ID" ] || [ -z "$ARM_SUBSCRIPTION_ID" ]; then
    echo "Error: Failed to set one or more environment variables"
    echo ""
    echo "Check that sp_output.json contains valid JSON with:"
    echo "  - appId"
    echo "  - password"
    echo "  - tenant"
    exit 1
fi

echo "✓ Environment variables set successfully:"
echo "  ARM_CLIENT_ID: ${ARM_CLIENT_ID:0:8}..." # Show only first 8 chars for security
echo "  ARM_TENANT_ID: $ARM_TENANT_ID"
echo "  ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
echo ""
echo "Note: These variables are only available in the current shell session."
echo "To make them persistent, add them to your ~/.bashrc or use a .env file."
echo ""
echo "To verify authentication, run: ./verify_auth.sh"

