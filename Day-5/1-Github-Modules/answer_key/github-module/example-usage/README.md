# Example: Using VM Module from GitHub

This directory contains an example Terraform configuration that uses the VM module from GitHub.

## Prerequisites

1. **Module Published to GitHub**
   - The VM module must be published to GitHub first
   - See `publish_module_to_github_task.md` for instructions

2. **Update Module Source**
   - Edit `main.tf` and replace `YOUR_USERNAME` with your GitHub username
   - Ensure the version tag exists (e.g., `v1.0.0`)

3. **Azure Authentication**
   - Ensure you're authenticated with Azure
   - Run `az login` if needed

## Usage

### 1. Update Module Source

Edit `main.tf` and update the module source:

```hcl
module "vm" {
  source = "github.com/YOUR_ACTUAL_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  # ... rest of configuration
}
```

### 2. Configure Variables

```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# Update ssh_public_key_path if needed
```

### 3. Initialize Terraform

```bash
# Initialize Terraform (will download module from GitHub)
terraform init

# Expected output:
# Initializing modules...
# - vm in
#   Downloading github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0 for vm...
```

### 4. Plan and Apply

```bash
# Review plan
terraform plan

# Apply (if plan looks good)
terraform apply
```

### 5. Verify

After apply completes:

```bash
# View outputs
terraform output

# SSH to VM (if SSH key is configured)
ssh azureuser@$(terraform output -raw vm_public_ip)
```

## What Gets Created

- Resource Group
- Virtual Network and Subnet (via module)
- Public IP Address (via module)
- Network Security Group (via module)
- Network Interface (via module)
- Linux Virtual Machine (via module)

## Module Outputs

The module provides these outputs:

- `vm_id` - VM resource ID
- `vm_name` - VM name
- `vm_public_ip` - Public IP address
- `vm_private_ip` - Private IP address
- `vnet_id` - Virtual Network ID
- `subnet_id` - Subnet ID
- `nsg_id` - Network Security Group ID

## Troubleshooting

### Module Not Found

If you get "module not found" error:

1. Verify repository exists:
   ```bash
   gh repo view YOUR_USERNAME/terraform-azurerm-vm
   ```

2. Check version tag exists:
   ```bash
   gh release list --repo YOUR_USERNAME/terraform-azurerm-vm
   ```

3. Clear Terraform cache:
   ```bash
   rm -rf .terraform
   terraform init
   ```

### Authentication Issues

If using a private repository:

```bash
# Setup Git credentials
gh auth setup-git

# Or use SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

## Next Steps

- Try different VM sizes
- Modify network configuration
- Add additional resources
- Create your own modules and publish them

