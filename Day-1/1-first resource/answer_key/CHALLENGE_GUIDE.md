# Challenge: Create Your First Virtual Machine

This guide will walk you through creating a simple Linux Virtual Machine in Azure using Terraform. You'll create all resources in a single `main.tf` file, along with `variables.tf` and `outputs.tf`.

## Prerequisites

Before starting, ensure you have:
- ✅ Azure CLI installed and authenticated (`az login`)
- ✅ Terraform installed (version >= 1.9.0)
- ✅ An SSH key pair generated (or use an existing one)
- ✅ Your Azure subscription ID

## Step-by-Step Guide

### Step 1: Set Up Your Terraform Configuration

Create a new directory for this challenge and navigate to it:

```bash
mkdir vm-challenge
cd vm-challenge
```

### Step 2: Create `main.tf`

Create a `main.tf` file with the following structure:

#### 2.1 Terraform and Provider Configuration

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8.0"
    }
  }
  required_version = ">=1.9.0"
}

provider "azurerm" {
  subscription_id = var.subscription_id != "" ? var.subscription_id : null
  features {}
}
```

**Explanation:**
- The `terraform` block specifies required providers and versions
- The `provider` block configures the Azure provider
- We use a variable for the subscription ID

#### 2.2 Resource Group

Every Azure resource must belong to a resource group:

```hcl
resource "azurerm_resource_group" "vm" {
  name     = var.resource_group_name
  location = var.location
}
```

**Key Points:**
- `resource` is the keyword to create a resource
- `azurerm_resource_group` is the resource type
- `vm` is the local name (used for references)
- `name` and `location` are required attributes

#### 2.3 Virtual Network

A VM needs a network to connect to:

```hcl
resource "azurerm_virtual_network" "vm" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name
}
```

**Key Points:**
- `address_space` defines the IP range for the network
- We reference the resource group using `azurerm_resource_group.vm.location`
- String interpolation: `"${var.vm_name}-vnet"` combines variables with strings

#### 2.4 Subnet

Subnets divide the virtual network:

```hcl
resource "azurerm_subnet" "vm" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.vm.name
  virtual_network_name = azurerm_virtual_network.vm.name
  address_prefixes     = ["10.0.1.0/24"]
}
```

**Key Points:**
- The subnet must be within the VNet's address space
- `10.0.1.0/24` is a subset of `10.0.0.0/16`

#### 2.5 Network Interface

The network interface connects the VM to the network:

```hcl
resource "azurerm_network_interface" "vm" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.vm.location
  resource_group_name = azurerm_resource_group.vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

**Key Points:**
- `subnet_id` references the subnet using `.id`
- `Dynamic` allocation means Azure assigns the IP automatically

#### 2.6 Virtual Machine

Finally, create the VM:

```hcl
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.vm.name
  location            = azurerm_resource_group.vm.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
```

**Key Points:**
- `size` determines VM performance and cost (e.g., `Standard_B1s` is a small, low-cost VM)
- `admin_ssh_key` allows SSH access using your public key
- `source_image_reference` specifies the OS image (Ubuntu 22.04 LTS)
- `os_disk` configures the VM's storage

### Step 3: Create `variables.tf`

Create a `variables.tf` file to define all variables:

```hcl
variable "subscription_id" {
  type        = string
  description = "The subscription ID to use for the Azure resources"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "vm-resources"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "West Europe"
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
  default     = "my-first-vm"
}

variable "vm_size" {
  type        = string
  description = "Size of the virtual machine (e.g., Standard_B1s, Standard_B2s)"
  default     = "Standard_B1s"
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the VM"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM authentication"
  sensitive   = true
}
```

**Key Points:**
- Variables with `default` values are optional
- `sensitive = true` prevents the value from being displayed in logs
- Always include descriptions for clarity

### Step 4: Create `outputs.tf`

Create an `outputs.tf` file to display useful information:

```hcl
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.vm.name
}

output "vm_name" {
  description = "Name of the created virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine (if available)"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "vm_location" {
  description = "Location where the VM was created"
  value       = azurerm_linux_virtual_machine.vm.location
}

output "vm_size" {
  description = "Size of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.size
}
```

**Key Points:**
- Outputs display information after `terraform apply`
- Use outputs to get resource IDs, names, or other important values

### Step 5: Generate or Use an SSH Key

If you don't have an SSH key, generate one:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Get your public key:

```bash
# On Linux/Mac
cat ~/.ssh/id_rsa.pub

# On Windows (PowerShell)
Get-Content ~/.ssh/id_rsa.pub
```

### Step 6: Initialize Terraform

Run Terraform initialization to download providers:

```bash
terraform init
```

### Step 7: Create a `terraform.tfvars` File (Optional)

Create a `terraform.tfvars` file to set variable values:

```hcl
subscription_id = "your-subscription-id-here"
resource_group_name = "my-vm-resources"
location = "West Europe"
vm_name = "my-first-vm"
vm_size = "Standard_B1s"
admin_username = "azureuser"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your-public-key-here"
```

**Note:** Alternatively, you can pass variables via command line or environment variables.

### Step 8: Plan Your Deployment

Review what Terraform will create:

```bash
terraform plan
```

This shows you:
- Resources that will be created
- Resources that will be modified
- Resources that will be destroyed

### Step 9: Apply Your Configuration

Create the resources:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 10: Verify Outputs

After applying, Terraform will display your outputs. You can also view them anytime:

```bash
terraform output
```

### Step 11: Connect to Your VM via SSH

Once your VM is created, you can connect to it using SSH.

#### Default Username

The default username is **`azureuser`** (as defined in the `admin_username` variable).

#### Getting the VM's IP Address

The current configuration creates a VM with only a **private IP address**. To get the private IP:

```bash
terraform output vm_public_ip
```

**Note:** This output actually shows the private IP address. The name is a bit misleading in the current setup.

#### SSH Command

From a Linux VM or your local machine, use this command to connect:

```bash
ssh -i ~/.ssh/id_rsa azureuser@<VM_PRIVATE_IP>
```

Replace `<VM_PRIVATE_IP>` with the IP address from the output.

**Example:**
```bash
# Get the IP address
VM_IP=$(terraform output -raw vm_public_ip)

# Connect via SSH
ssh -i ~/.ssh/id_rsa azureuser@$VM_IP
```

#### Important Notes

1. **Private IP Access:** Since the VM only has a private IP, you can only SSH from:
   - Another VM in the same Azure Virtual Network
   - A machine connected via VPN to the Azure network
   - A machine using Azure Bastion (if configured)

2. **Public IP Access:** To SSH from the internet, you'll need to complete **Challenge 4** (Add a Public IP) below.

3. **SSH Key:** Make sure you're using the **private key** that corresponds to the public key you provided in `terraform.tfvars`. The default location is `~/.ssh/id_rsa`.

4. **First Connection:** On first connection, you'll be asked to verify the host's authenticity. Type `yes` to continue.

## Understanding Resource Dependencies

Notice how resources reference each other:

- **Resource Group** → Referenced by all other resources
- **Virtual Network** → Referenced by Subnet
- **Subnet** → Referenced by Network Interface
- **Network Interface** → Referenced by Virtual Machine

Terraform automatically handles these dependencies and creates resources in the correct order.

## Clean Up

When you're done, destroy all resources:

```bash
terraform destroy
```

## Common Issues and Solutions

### Issue: "Invalid subscription ID"
**Solution:** Ensure your subscription ID is correct. Get it with:
```bash
az account show --query id -o tsv
```

### Issue: "SSH key format invalid"
**Solution:** Ensure your SSH public key is in the correct format (starts with `ssh-rsa`, `ssh-ed25519`, etc.)

### Issue: "VM size not available in location"
**Solution:** Try a different location or VM size. Check available sizes:
```bash
az vm list-sizes --location "West Europe" --output table
```

### Issue: "Resource group name already exists"
**Solution:** Change the `resource_group_name` variable or delete the existing resource group.

## Additional Learning

- **Resource Documentation:** https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **VM Sizes:** https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
- **Terraform Language:** https://developer.hashicorp.com/terraform/language

---

## 🎯 Challenge: Change the VM Type

Now that you've created a Linux VM, try these challenges:

### Challenge 1: Switch to Windows VM
Convert your Linux VM to a Windows VM. You'll need to:
1. Change from `azurerm_linux_virtual_machine` to `azurerm_windows_virtual_machine`
2. Update the `source_image_reference` to use a Windows image (e.g., `WindowsServer`)
3. Replace `admin_ssh_key` with `admin_password` or use Azure Key Vault
4. Update variables accordingly

**Hint:** Look up `azurerm_windows_virtual_machine` in the Terraform Azure provider documentation.

### Challenge 2: Use a Different Linux Distribution
Change from Ubuntu to another Linux distribution:
- **Red Hat Enterprise Linux (RHEL)**
- **SUSE Linux Enterprise Server (SLES)**
- **Debian**
- **CentOS**

**Hint:** Search for the publisher, offer, and SKU in Azure Marketplace or use:
```bash
az vm image list --publisher Canonical --all --output table
```

### Challenge 3: Upgrade VM Size
Change the VM size to a more powerful one:
- From `Standard_B1s` to `Standard_B2s` or `Standard_D2s_v3`
- Compare the differences in CPU, memory, and cost

**Hint:** Use `az vm list-sizes --location "West Europe" --output table` to see available sizes.

### Challenge 4: Add a Public IP
Add a public IP address so you can SSH into the VM from the internet:
1. Create an `azurerm_public_ip` resource
2. Associate it with the network interface's `ip_configuration`
3. Update outputs to show the public IP

**Hint:** Look up `azurerm_public_ip` resource and how to associate it with a network interface.

**After completing this challenge**, you'll be able to SSH from anywhere using:
```bash
ssh -i ~/.ssh/id_rsa azureuser@<VM_PUBLIC_IP>
```
Where `<VM_PUBLIC_IP>` is the public IP address from your Terraform outputs.

---

## Success Criteria

✅ You can successfully run `terraform plan` without errors  
✅ You can successfully run `terraform apply` and create the VM  
✅ You understand how resources reference each other  
✅ You can modify the VM configuration and reapply  
✅ You can complete at least one of the challenges above  

Good luck! 🚀

