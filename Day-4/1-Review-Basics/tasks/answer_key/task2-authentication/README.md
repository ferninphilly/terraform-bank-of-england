# Task 2: Azure Authentication - Complete Answer Key

This directory contains scripts and examples for authenticating Terraform with Azure on Linux using a Service Principal.

## Files Overview

- `set_vars.sh` - Script to automatically set environment variables from sp_output.json
- `verify_auth.sh` - Script to verify authentication is configured correctly
- `test_auth.tf` - Test Terraform configuration to verify authentication works
- `README.md` - This file

## Prerequisites

1. Azure CLI installed and configured
2. Terraform installed (>= 1.5.0)
3. jq installed (for parsing JSON)
4. An active Azure subscription
5. Service Principal created (see steps below)

## Step-by-Step Usage

### Step 1: Create Service Principal

```bash
# Login to Azure CLI
az login

# Set your subscription (if you have multiple)
az account set --subscription "Your Subscription Name"

# Create Service Principal and save output
az ad sp create-for-rbac \
  --role="Contributor" \
  --scopes="/subscriptions/$(az account show --query id -o tsv)" \
  --name "http://terraform-service-principal" \
  > sp_output.json
```

**⚠️ IMPORTANT:** Save `sp_output.json` securely! The password is shown only once.

### Step 2: Set Environment Variables

Make the script executable and source it:

```bash
chmod +x set_vars.sh
source ./set_vars.sh
```

Or use dot notation:

```bash
. ./set_vars.sh
```

**Note:** You must `source` the script (not execute it) so variables are set in your current shell.

### Step 3: Verify Authentication

```bash
chmod +x verify_auth.sh
./verify_auth.sh
```

This will check:
- All environment variables are set
- Azure CLI is authenticated
- Terraform is installed

### Step 4: Test Terraform Authentication

```bash
# Initialize Terraform (downloads Azure provider)
terraform init

# Validate configuration
terraform validate

# Plan (tests authentication)
terraform plan
```

If successful, you'll see subscription information without errors.

### Step 5: Clean Up Test Files

```bash
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

## Environment Variables

The following environment variables are set by `set_vars.sh`:

| Variable | Description | Source |
|----------|-------------|--------|
| `ARM_CLIENT_ID` | Service Principal Application ID | sp_output.json (appId) |
| `ARM_CLIENT_SECRET` | Service Principal Password | sp_output.json (password) |
| `ARM_TENANT_ID` | Azure AD Tenant ID | sp_output.json (tenant) |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID | Azure CLI (az account show) |

## Making Variables Persistent

### Option 1: Add to Shell Profile

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
```

Then reload:
```bash
source ~/.bashrc
```

### Option 2: Use .env File

Create `.env` file:
```bash
ARM_CLIENT_ID=your-client-id
ARM_CLIENT_SECRET=your-client-secret
ARM_TENANT_ID=your-tenant-id
ARM_SUBSCRIPTION_ID=your-subscription-id
```

Load before running Terraform:
```bash
set -a
source .env
set +a
terraform plan
```

**⚠️ Security:** Add `.env` to `.gitignore` to prevent committing secrets!

## Troubleshooting

### "sp_output.json not found"
- Ensure you've created the Service Principal and saved output to `sp_output.json`
- Check file exists: `ls -la sp_output.json`

### "jq: command not found"
- Install jq: `sudo apt-get install jq` (Ubuntu/Debian)
- Or manually extract values from sp_output.json

### "ARM_CLIENT_ID is not set"
- You need to `source` the script, not execute it: `source ./set_vars.sh`
- Check sp_output.json contains valid JSON

### "Azure CLI is not authenticated"
- Run: `az login` or `az login --use-device-code`
- Verify: `az account show`

### "Error: building AzureRM Client"
- Environment variables not set in current shell
- Run: `source ./set_vars.sh`
- Verify: `echo $ARM_CLIENT_ID`

## Security Best Practices

1. **Protect sp_output.json**
   - Use file permissions: `chmod 600 sp_output.json`
   - Never commit to version control
   - Add to `.gitignore`

2. **Rotate Credentials**
   - Service Principal passwords don't expire automatically
   - Rotate regularly (every 90 days recommended)
   - Create new Service Principal if password is lost

3. **Use Least Privilege**
   - Use `Contributor` role instead of `Owner` when possible
   - Scope to specific resource groups if needed

4. **Monitor Usage**
   - Enable Azure AD audit logs
   - Review Service Principal activity regularly

## Next Steps

Once authentication is verified, you can:
- Create your first Azure resource with Terraform
- Use the VM setup configuration (Task 1)
- Set up remote state storage
- Explore Terraform modules

## Additional Resources

- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Service Principal Best Practices](https://docs.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals)

