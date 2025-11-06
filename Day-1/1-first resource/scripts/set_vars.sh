#!/bin/bash

# NOTE: This script is for Linux/macOS (Bash).
# Before running, ensure you have run 'az ad sp create-for-rbac'
# and saved its JSON output to a file named 'sp_output.json' in this directory.

echo "Reading credentials from sp_output.json..."

# Check if the credentials file exists
if [ ! -f "sp_output.json" ]; then
    echo "Error: 'sp_output.json' not found."
    echo "Please ensure you save the JSON output from Step 1 into this file."
    exit 1
fi

# Use 'jq' (JSON processor) to extract values and set environment variables
# Note: 'jq' must be installed (e.g., 'brew install jq' or 'sudo apt install jq')

export ARM_CLIENT_ID=$(jq -r '.appId' sp_output.json)
export ARM_CLIENT_SECRET=$(jq -r '.password' sp_output.json)
export ARM_TENANT_ID=$(jq -r '.tenant' sp_output.json)

# Get the Subscription ID using the Azure CLI
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo "Environment variables set for Terraform:"
echo "ARM_CLIENT_ID: $ARM_CLIENT_ID"
echo "ARM_TENANT_ID: $ARM_TENANT_ID"
echo "ARM_SUBSCRIPTION_ID: $ARM_SUBSCRIPTION_ID"
echo "Use 'source ./set_vars.sh' to apply these variables in your current shell."