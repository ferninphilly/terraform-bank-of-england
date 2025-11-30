#!/bin/bash

# Script to create Azure Storage Account and Container for Terraform state
# This script automates the creation of backend infrastructure

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Create Azure Storage for Terraform State"
echo "=========================================="
echo ""

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-tfstate-rg}"
STORAGE_PREFIX="${STORAGE_PREFIX:-tfstatestorage}"
LOCATION="${LOCATION:-eastus}"
CONTAINER_NAME="${CONTAINER_NAME:-tfstate}"

# Generate random suffix for storage account (must be globally unique)
RANDOM_SUFFIX=$(openssl rand -hex 2)
STORAGE_ACCOUNT="${STORAGE_PREFIX}${RANDOM_SUFFIX}"

echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Storage Account: $STORAGE_ACCOUNT"
echo "  Container: $CONTAINER_NAME"
echo "  Location: $LOCATION"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}✗${NC} Azure CLI not found"
    echo "   Install it first: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Check if logged in
if ! az account show &> /dev/null; then
    echo -e "${RED}✗${NC} Not logged in to Azure"
    echo "   Run: az login"
    exit 1
fi

echo -e "${GREEN}✓${NC} Azure CLI installed and authenticated"
echo ""

# Create resource group
echo "Creating resource group..."
if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} Resource group already exists: $RESOURCE_GROUP"
else
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --output none
    echo -e "${GREEN}✓${NC} Resource group created: $RESOURCE_GROUP"
fi
echo ""

# Create storage account
echo "Creating storage account..."
if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} Storage account already exists: $STORAGE_ACCOUNT"
else
    az storage account create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$STORAGE_ACCOUNT" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --location "$LOCATION" \
        --allow-blob-public-access false \
        --min-tls-version TLS1_2 \
        --output none
    echo -e "${GREEN}✓${NC} Storage account created: $STORAGE_ACCOUNT"
fi
echo ""

# Get storage account key
echo "Getting storage account key..."
STORAGE_KEY=$(az storage account keys list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$STORAGE_ACCOUNT" \
    --query '[0].value' -o tsv)
echo -e "${GREEN}✓${NC} Storage key retrieved"
echo ""

# Create container
echo "Creating blob container..."
if az storage container show \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} Container already exists: $CONTAINER_NAME"
else
    az storage container create \
        --name "$CONTAINER_NAME" \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$STORAGE_KEY" \
        --public-access off \
        --output none
    echo -e "${GREEN}✓${NC} Container created: $CONTAINER_NAME"
fi
echo ""

# Enable versioning
echo "Enabling blob versioning..."
az storage account blob-service-properties update \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --enable-versioning true \
    --output none
echo -e "${GREEN}✓${NC} Blob versioning enabled"
echo ""

# Enable soft delete
echo "Enabling soft delete..."
az storage account blob-service-properties update \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --enable-delete-retention true \
    --delete-retention-days 30 \
    --output none
echo -e "${GREEN}✓${NC} Soft delete enabled (30 days)"
echo ""

# Output backend configuration
echo "=========================================="
echo "Backend Configuration"
echo "=========================================="
echo ""
echo "Add this to your backend.tf file:"
echo ""
cat << EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP"
    storage_account_name = "$STORAGE_ACCOUNT"
    container_name       = "$CONTAINER_NAME"
    key                  = "terraform.tfstate"
  }
}
EOF
echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "${GREEN}✓${NC} Resource Group: $RESOURCE_GROUP"
echo -e "${GREEN}✓${NC} Storage Account: $STORAGE_ACCOUNT"
echo -e "${GREEN}✓${NC} Container: $CONTAINER_NAME"
echo -e "${GREEN}✓${NC} Versioning: Enabled"
echo -e "${GREEN}✓${NC} Soft Delete: Enabled (30 days)"
echo ""
echo "Next steps:"
echo "  1. Copy the backend configuration above"
echo "  2. Create backend.tf in your Terraform project"
echo "  3. Run: terraform init"
echo ""

