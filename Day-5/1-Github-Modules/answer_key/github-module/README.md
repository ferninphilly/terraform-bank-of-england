# Answer Key: Publishing Terraform Module to GitHub

This directory contains the complete answer key for publishing a Terraform module to GitHub and using it from remote sources.

## Directory Structure

```
github-module/
├── modules/
│   └── vm/                    # VM module ready for GitHub
│       ├── main.tf            # Module resources
│       ├── variables.tf       # Module variables
│       ├── outputs.tf         # Module outputs
│       ├── README.md          # Module documentation
│       └── .gitignore         # Git ignore rules
├── example-usage/             # Example using module from GitHub
│   ├── main.tf               # Root module using GitHub module
│   ├── variables.tf           # Root module variables
│   ├── output.tf              # Root module outputs
│   ├── terraform.tfvars.example # Example variables
│   └── README.md              # Usage instructions
├── publish_script.sh          # Automated publish script
└── README.md                  # This file
```

## Quick Start

### Option 1: Manual Publishing

1. **Navigate to module directory:**
   ```bash
   cd modules/vm
   ```

2. **Initialize Git:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: Azure VM module"
   ```

3. **Create GitHub repository:**
   ```bash
   gh repo create terraform-azurerm-vm \
     --public \
     --description "Terraform module for Azure Linux VM with networking"
   ```

4. **Push to GitHub:**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/terraform-azurerm-vm.git
   git branch -M main
   git push -u origin main
   ```

5. **Create version tag:**
   ```bash
   git tag -a v1.0.0 -m "Initial release"
   git push origin v1.0.0
   ```

6. **Create release:**
   ```bash
   gh release create v1.0.0 \
     --title "v1.0.0 - Initial Release" \
     --notes "Initial release of Azure VM module"
   ```

### Option 2: Automated Script

Use the provided script to automate the process:

```bash
# From the github-module directory
./publish_script.sh
```

The script will:
- ✅ Check prerequisites (GitHub CLI, authentication)
- ✅ Initialize Git repository
- ✅ Create GitHub repository
- ✅ Push code to GitHub
- ✅ Create version tag
- ✅ Create GitHub release

## Using the Module

After publishing, use the module in your Terraform configurations:

```hcl
module "vm" {
  source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"
  
  name_prefix        = "myvm"
  resource_group_name = "my-rg"
  location           = "eastus"
  vm_size            = "Standard_B2s"
  admin_username     = "azureuser"
  ssh_public_key_path = "~/.ssh/id_rsa.pub"
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

See `example-usage/` directory for a complete example.

## Module Contents

### VM Module (`modules/vm/`)

**Resources Created:**
- Virtual Network
- Subnet
- Public IP Address
- Network Security Group (SSH, HTTP rules)
- Network Interface
- Linux Virtual Machine (Ubuntu 22.04 LTS)

**Key Features:**
- Configurable VM sizes
- SSH key authentication
- Complete networking setup
- Tag support

**Inputs:**
- `name_prefix` - Prefix for resource names
- `resource_group_name` - Resource group name
- `location` - Azure region
- `vm_size` - VM size (default: Standard_B1s)
- `admin_username` - Admin username (default: azureuser)
- `ssh_public_key_path` - Path to SSH public key
- `vnet_address_space` - VNet address space
- `subnet_address_prefix` - Subnet address prefix
- `tags` - Resource tags

**Outputs:**
- `vm_id` - VM resource ID
- `vm_name` - VM name
- `vm_public_ip` - Public IP address
- `vm_private_ip` - Private IP address
- `vnet_id` - Virtual Network ID
- `subnet_id` - Subnet ID
- `nsg_id` - Network Security Group ID

## Example Usage

The `example-usage/` directory contains a complete example:

```bash
cd example-usage

# Update main.tf with your GitHub username
# Edit: source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.0.0"

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize and apply
terraform init
terraform plan
terraform apply
```

## Versioning

The module uses semantic versioning:

- **v1.0.0** - Initial release
- **v1.1.0** - New features (backward compatible)
- **v2.0.0** - Breaking changes

To create a new version:

```bash
cd modules/vm

# Make changes
# ... edit files ...

# Commit changes
git add .
git commit -m "Add new feature"

# Push changes
git push origin main

# Create new version tag
git tag -a v1.1.0 -m "Add new feature"
git push origin v1.1.0

# Create release
gh release create v1.1.0 \
  --title "v1.1.0 - New Feature" \
  --notes "Added new feature"
```

## Troubleshooting

### Module Not Found

If Terraform can't find the module:

1. **Verify repository exists:**
   ```bash
   gh repo view YOUR_USERNAME/terraform-azurerm-vm
   ```

2. **Check version tag:**
   ```bash
   gh release list --repo YOUR_USERNAME/terraform-azurerm-vm
   ```

3. **Clear Terraform cache:**
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

### Update Module Version

To upgrade to a new module version:

```bash
# Update source in main.tf
# source = "github.com/YOUR_USERNAME/terraform-azurerm-vm?ref=v1.1.0"

# Upgrade module
terraform init -upgrade

# Review changes
terraform plan
```

## Best Practices

1. **Version Pinning**: Always use specific version tags (`?ref=v1.0.0`)
2. **Documentation**: Keep README.md updated
3. **Testing**: Test modules before publishing
4. **Semantic Versioning**: Follow semantic versioning principles
5. **Release Notes**: Document changes in release notes
6. **Examples**: Provide usage examples

## Next Steps

- Publish additional modules
- Create module examples
- Set up module testing
- Explore module composition
- Share modules with your team

## Resources

- [Module Publishing Guide](../../publish_module_to_github_task.md)
- [Module README Template](../../module_readme_template.md)
- [Quick Reference](../../quick_reference.md)
- [Terraform Module Sources](https://www.terraform.io/docs/language/modules/sources.html)

