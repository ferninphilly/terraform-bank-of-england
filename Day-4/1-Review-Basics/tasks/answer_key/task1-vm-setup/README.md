# Task 1: VM Setup - Complete Answer Key

This directory contains the complete Terraform configuration for creating a Virtual Machine with network infrastructure in Azure.

## Files Overview

- `backend.tf` - Terraform backend configuration (remote state storage)
- `provider.tf` - Azure provider configuration
- `variables.tf` - Variable definitions with validation
- `rg.tf` - Resource group creation
- `network.tf` - Virtual network, subnet, public IP, NSG, and NIC
- `vm.tf` - Linux virtual machine configuration
- `output.tf` - Output values for important information
- `terraform.tfvars.example` - Example variable values

## Prerequisites

1. Azure authentication configured (see Task 2)
2. SSH key pair generated
3. Terraform installed (>= 1.5.0)
4. **Backend Storage Account**: The backend.tf file references a remote state storage account. Ensure you have:
   - Resource group: `tfstate-rg`
   - Storage account: `tfstatestorage`
   - Container: `tfstate`
   
   **Note:** If these don't exist, you can either:
   - Create them manually in Azure, OR
   - Comment out the backend block in `backend.tf` to use local state initially

## Important Notes

### Public IP SKU: Standard vs Basic

This configuration uses **Standard SKU** for the public IP address instead of Basic SKU. This is intentional to avoid quota limitations:

- **Basic SKU**: Free tier, but has strict quota limits (often 0-5 per region per subscription)
- **Standard SKU**: Slightly more expensive, but has much higher quotas (100+ per region)
- Many free/trial Azure subscriptions have **0 Basic public IP quota**, which causes deployment failures

**If you encounter quota errors**, see the troubleshooting section in `setup_vm_task_review.md` for solutions.

## Usage

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars with your values:**
   - Update `resource_group_name`
   - Update `location` (must be in allowed regions)
   - Update `ssh_public_key_path` to point to your SSH public key
   - Customize tags as needed

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```
   
   **Note:** If using remote backend, Terraform will prompt you to migrate state. Type `yes` if this is a new setup.

4. **Review the plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Connect to the VM:**
   ```bash
   ssh azureuser@<public_ip_from_output>
   ```

7. **Destroy resources when done:**
   ```bash
   terraform destroy
   ```

## Important Notes

- **SSH Key**: Ensure your SSH public key exists at the path specified in `ssh_public_key_path`
- **Resource Names**: Azure resource names must be globally unique
- **Costs**: Running VMs incur charges. Destroy resources when not in use
- **Security**: The NSG allows SSH from anywhere (`*`). For production, restrict to your IP

## Customization

### Change VM Size
Edit `terraform.tfvars`:
```hcl
vm_size = "Standard_B2s"  # 2 vCPU, 4GB RAM
```

### Change OS Image
Edit `vm.tf`:
```hcl
source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"  # Ubuntu 20.04
  sku       = "20_04-lts-gen2"
  version   = "latest"
}
```

### Restrict SSH Access
Edit `network.tf` security rule:
```hcl
source_address_prefix = "YOUR_IP_ADDRESS/32"  # Replace with your IP
```

## Backend Configuration

The `backend.tf` file configures remote state storage in Azure. This allows:
- State file to be stored securely in Azure Storage
- Team collaboration (shared state)
- State locking to prevent conflicts

**Backend Settings:**
- Resource Group: `tfstate-rg`
- Storage Account: `tfstatestorage`
- Container: `tfstate`
- State File Key: `vm-review.terraform.tfstate`

**To use local state instead** (for testing), comment out the backend block:
```hcl
# backend "azurerm" {
#   ...
# }
```

## Troubleshooting

- **"SSH key file not found"**: Verify the path in `ssh_public_key_path`
- **"Resource name already exists"**: Change `name_prefix` in terraform.tfvars
- **"Location not allowed"**: Use one of the allowed regions in variables.tf
- **"Backend storage account not found"**: Create the storage account and container, or comment out the backend block to use local state

