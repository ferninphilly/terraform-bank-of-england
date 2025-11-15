# 🚀 Deploy Your First Azure VM - Step-by-Step Guide

This guide will walk you through deploying your first Linux Virtual Machine in Azure using Terraform. You'll learn how to create all the necessary networking components and configure the VM for SSH access.

## 📚 Learning Objectives

By the end of this guide, you will:
- Understand the components needed for an Azure VM
- Create a Virtual Network and Subnet
- Configure Network Security Groups (NSG)
- Set up Public IP addresses
- Deploy a Linux VM with SSH access
- Connect to your VM via SSH

---

## 🎯 Prerequisites

Before starting, ensure you have:
- Terraform installed (version >= 1.5.7)
- Azure CLI installed and configured
- Azure subscription with appropriate permissions
- SSH key pair generated (`azure-vm-key` and `azure-vm-key.pub`)
- Service Principal authentication configured (or Azure CLI login)

---

## 📝 Step 1: Generate SSH Key Pair

Before creating the VM, you need an SSH key pair for secure access.

### Step 1.1: Generate SSH Keys

1. **Open a terminal** in your project directory

2. **Generate SSH key pair:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f azure-vm-key -N ""
   ```

3. **Verify keys were created:**
   ```bash
   ls -la azure-vm-key*
   ```

   You should see:
   - `azure-vm-key` (private key - keep this secret!)
   - `azure-vm-key.pub` (public key - will be added to VM)

**⚠️ Important:** Never commit the private key (`azure-vm-key`) to version control!

---

## 📝 Step 2: Create Provider Configuration

### Step 2.1: Create `provider.tf`

1. **Create `provider.tf` file:**
   ```terraform
   terraform {
     required_providers {
       azurerm = {
         source  = "hashicorp/azurerm"
         version = "~> 4.8.0"
       }
     }
     required_version = ">= 1.5.7"
   }

   provider "azurerm" {
     features {}
   }
   ```

2. **Save the file**

**💡 Note:** The provider block is empty because it relies on environment variables (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`) or Azure CLI authentication.

---

## 📝 Step 3: Create Resource Group

### Step 3.1: Add Resource Group to `main.tf`

1. **Create `main.tf` file** (or open if it exists)

2. **Add the resource group:**
   ```terraform
   # Resource Group
   resource "azurerm_resource_group" "rg_lesson" {
     name     = "terraform-vm-lesson-rg"
     location = "West Europe"
   }
   ```

**Understanding:**
- `name` - Name of the resource group
- `location` - Azure region where resources will be created

---

## 📝 Step 4: Create Virtual Network and Subnet

### Step 4.1: Add Virtual Network

1. **Add to `main.tf`:**
   ```terraform
   # Virtual Network
   resource "azurerm_virtual_network" "vnet" {
     name                = "vnet-lesson"
     address_space       = ["10.0.0.0/16"]
     location            = azurerm_resource_group.rg_lesson.location
     resource_group_name = azurerm_resource_group.rg_lesson.name
   }
   ```

**Understanding:**
- `address_space` - CIDR block for the entire VNet (10.0.0.0/16 = 65,536 IP addresses)
- `location` - Uses the resource group's location (implicit dependency)
- `resource_group_name` - References the resource group we created

### Step 4.2: Add Subnet

1. **Add subnet to `main.tf`:**
   ```terraform
   # Subnet
   resource "azurerm_subnet" "subnet" {
     name                 = "subnet-lesson"
     resource_group_name  = azurerm_resource_group.rg_lesson.name
     virtual_network_name = azurerm_virtual_network.vnet.name
     address_prefixes     = ["10.0.1.0/24"]
   }
   ```

**Understanding:**
- `address_prefixes` - CIDR block for this subnet (10.0.1.0/24 = 256 IP addresses)
- Must be within the VNet's address space
- `virtual_network_name` - References the VNet we created

---

## 📝 Step 5: Create Public IP Address

### Step 5.1: Add Public IP Resource

1. **Add to `main.tf`:**
   ```terraform
   # Public IP Address
   resource "azurerm_public_ip" "public_ip" {
     name                = "public-ip-lesson"
     location            = azurerm_resource_group.rg_lesson.location
     resource_group_name = azurerm_resource_group.rg_lesson.name
     allocation_method   = "Dynamic"
   }
   ```

**Understanding:**
- `allocation_method` - "Dynamic" (assigned at runtime) or "Static" (fixed IP)
- Dynamic IPs are free but change when VM is stopped/deallocated
- Static IPs cost extra but remain constant

---

## 📝 Step 6: Create Network Security Group (NSG)

### Step 6.1: Add NSG Resource

1. **Add to `main.tf`:**
   ```terraform
   # Network Security Group
   resource "azurerm_network_security_group" "nsg" {
     name                = "nsg-lesson"
     location            = azurerm_resource_group.rg_lesson.location
     resource_group_name = azurerm_resource_group.rg_lesson.name

     security_rule {
       name                       = "SSH_Inbound"
       priority                   = 1001
       direction                  = "Inbound"
       access                     = "Allow"
       protocol                   = "Tcp"
       source_port_range          = "*"
       destination_port_range     = "22"
       source_address_prefix      = "Internet"
       destination_address_prefix = "*"
     }
   }
   ```

**Understanding:**
- `security_rule` - Defines firewall rules
- `priority` - Lower numbers = higher priority (100-4096)
- `direction` - "Inbound" (to VM) or "Outbound" (from VM)
- `protocol` - "Tcp", "Udp", or "*" (all)
- `destination_port_range` - Port 22 for SSH
- `source_address_prefix` - "Internet" allows from anywhere (use with caution!)

**⚠️ Security Note:** In production, restrict `source_address_prefix` to specific IP addresses!

---

## 📝 Step 7: Create Network Interface (NIC)

### Step 7.1: Add NIC Resource

1. **Add to `main.tf`:**
   ```terraform
   # Network Interface
   resource "azurerm_network_interface" "nic" {
     name                = "nic-lesson"
     location            = azurerm_resource_group.rg_lesson.location
     resource_group_name = azurerm_resource_group.rg_lesson.name

     ip_configuration {
       name                          = "internal"
       subnet_id                     = azurerm_subnet.subnet.id
       private_ip_address_allocation = "Dynamic"
       public_ip_address_id          = azurerm_public_ip.public_ip.id
     }
   }
   ```

**Understanding:**
- `ip_configuration` - Defines IP settings for the NIC
- `subnet_id` - Links NIC to the subnet
- `private_ip_address_allocation` - "Dynamic" (auto-assigned) or "Static"
- `public_ip_address_id` - Attaches the public IP

### Step 7.2: Associate NSG with NIC

1. **Add NSG association:**
   ```terraform
   # Associate NSG with NIC
   resource "azurerm_network_interface_security_group_association" "nic_nsg_associate" {
     network_interface_id      = azurerm_network_interface.nic.id
     network_security_group_id = azurerm_network_security_group.nsg.id
   }
   ```

**Understanding:**
- This applies the NSG rules to the network interface
- Alternative: You can attach NSG directly to subnet

---

## 📝 Step 8: Create Linux Virtual Machine

### Step 8.1: Add VM Resource

1. **Add to `main.tf`:**
   ```terraform
   # Linux Virtual Machine
   resource "azurerm_linux_virtual_machine" "vm" {
     name                  = "smallest-linux-vm"
     resource_group_name   = azurerm_resource_group.rg_lesson.name
     location              = azurerm_resource_group.rg_lesson.location
     size                  = "Standard_B1ls"  # Smallest size for cost efficiency
     admin_username        = "azureuser"
     network_interface_ids = [azurerm_network_interface.nic.id]
     disable_password_authentication = true

     # SSH Public Key
     admin_ssh_key {
       username   = "azureuser"
       public_key = file("${path.module}/azure-vm-key.pub")
     }

     # Ubuntu 20.04 LTS Image
     source_image_reference {
       publisher = "Canonical"
       offer     = "0001-com-ubuntu-server-focal"
       sku       = "20_04-lts-gen2"
       version   = "latest"
     }

     # OS Disk Configuration
     os_disk {
       caching              = "ReadWrite"
       storage_account_type = "Standard_LRS"
     }
   }
   ```

**Understanding:**
- `size` - VM size (Standard_B1ls is the smallest/cheapest)
- `admin_username` - Username for SSH access
- `network_interface_ids` - Links VM to the NIC (list format)
- `disable_password_authentication` - Only allows SSH key authentication
- `admin_ssh_key` - Adds your public SSH key
- `source_image_reference` - Specifies the OS image
- `os_disk` - Configures the VM's disk

**💡 VM Size Reference:**
- `Standard_B1ls` - 1 vCPU, 0.5 GB RAM (cheapest, ~$4/month)
- `Standard_B1s` - 1 vCPU, 1 GB RAM (~$8/month)
- `Standard_DS1_v2` - 1 vCPU, 3.5 GB RAM (~$50/month)

---

## 📝 Step 9: Add Output for Public IP

### Step 9.1: Create Output File

1. **Create `output.tf` file:**
   ```terraform
   output "public_ip_address" {
     description = "The public IP address to connect to the Linux VM via SSH."
     value       = azurerm_public_ip.public_ip.ip_address
   }
   ```

**Understanding:**
- Outputs display important values after `terraform apply`
- `ip_address` - The public IP assigned to your VM

---

## 📝 Step 10: Initialize and Deploy

### Step 10.1: Initialize Terraform

1. **Run initialization:**
   ```bash
   terraform init
   ```

2. **Verify** it completes successfully

### Step 10.2: Review the Plan

1. **Generate execution plan:**
   ```bash
   terraform plan
   ```

2. **Review the plan:**
   - Check that all resources will be created
   - Verify resource names and locations
   - Note the estimated costs (if shown)

### Step 10.3: Apply the Configuration

1. **Deploy the resources:**
   ```bash
   terraform apply
   ```

2. **Type `yes`** when prompted

3. **Wait for completion** (this may take 3-5 minutes)

4. **Note the output** - You should see the public IP address

---

## 📝 Step 11: Connect to Your VM

### Step 11.1: Get the Public IP

1. **View the output:**
   ```bash
   terraform output public_ip_address
   ```

   Or check the output from `terraform apply`

### Step 11.2: SSH into the VM

1. **Connect via SSH:**
   ```bash
   ssh -i azure-vm-key azureuser@<YOUR_PUBLIC_IP_ADDRESS>
   ```

   Replace `<YOUR_PUBLIC_IP_ADDRESS>` with the actual IP from the output

2. **First connection:** You may see a security warning - type `yes` to continue

3. **You should now be logged into your VM!** 🎉

### Step 11.3: Test the VM

Try these commands in the VM:
```bash
# Check system information
uname -a

# Check disk space
df -h

# Check network configuration
ip addr show

# Exit when done
exit
```

---

## 📝 Step 12: Clean Up Resources

### Step 12.1: Destroy Resources

**⚠️ Important:** Always destroy resources when done to avoid charges!

1. **Destroy all resources:**
   ```bash
   terraform destroy
   ```

2. **Type `yes`** when prompted

3. **Wait for completion**

4. **Verify** resources are deleted in Azure Portal

---

## 📊 Complete File Structure

Your project should now have:

```
Day-2/2-azure-shared-network-vm/
├── provider.tf          # Provider configuration
├── main.tf              # All resources
├── output.tf             # Output definitions
├── backend.tf           # Backend configuration (optional)
├── azure-vm-key         # Private SSH key (DO NOT COMMIT!)
└── azure-vm-key.pub     # Public SSH key
```

---

## 🎓 Key Concepts Learned

1. **Resource Dependencies:**
   - Resources reference each other (e.g., subnet → VNet)
   - Terraform handles dependency ordering automatically

2. **Networking Components:**
   - Virtual Network (VNet) - Logical network boundary
   - Subnet - Subdivision of VNet
   - Public IP - Internet-facing IP address
   - Network Interface (NIC) - Connects VM to network
   - Network Security Group (NSG) - Firewall rules

3. **VM Configuration:**
   - Size determines CPU/RAM
   - Image determines OS
   - SSH keys for secure access

4. **Security Best Practices:**
   - Use SSH keys instead of passwords
   - Restrict NSG rules to specific IPs in production
   - Keep private keys secure

---

## 🐛 Troubleshooting

### Issue: SSH Connection Refused

**Possible causes:**
- NSG rule not applied correctly
- Public IP not attached
- VM not fully provisioned

**Solutions:**
- Check NSG rules in Azure Portal
- Verify public IP is assigned
- Wait a few minutes and try again

### Issue: "Resource group not found"

**Solution:**
- Ensure resource group is created first
- Check resource group name spelling

### Issue: "SSH key file not found"

**Solution:**
- Verify `azure-vm-key.pub` exists in project directory
- Check file path in `main.tf`

### Issue: "Public IP allocation failed"

**Solution:**
- Try changing `allocation_method` to "Static"
- Check Azure subscription limits

---

## ✅ Verification Checklist

Before completing this guide, verify:

- [ ] SSH key pair generated successfully
- [ ] All Terraform files created correctly
- [ ] `terraform init` completed without errors
- [ ] `terraform plan` shows all resources to be created
- [ ] `terraform apply` completed successfully
- [ ] Public IP address displayed in output
- [ ] SSH connection to VM works
- [ ] VM responds to commands
- [ ] `terraform destroy` cleaned up all resources

---

## 🎉 Congratulations!

You've successfully deployed your first Azure VM with Terraform! You now understand:
- How to create Azure networking components
- How to configure a Linux VM
- How to connect via SSH
- How to manage infrastructure with Terraform

---

## 📚 Next Steps

- Try the exercises in `EXERCISES.md` to enhance your VM
- Add more networking components
- Experiment with different VM sizes
- Add additional security rules
- Implement string manipulation for resource naming

---

## 📚 Additional Resources

- [Azure VM Documentation](https://docs.microsoft.com/azure/virtual-machines/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Networking Overview](https://docs.microsoft.com/azure/networking/)
- [SSH Key Management](https://docs.microsoft.com/azure/virtual-machines/linux/create-ssh-keys-detailed)
