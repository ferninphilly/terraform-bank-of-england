# Step-by-Step Guide: Creating a Virtual Machine with Network in Terraform

This comprehensive guide walks you through creating a complete Azure Virtual Machine infrastructure using Terraform, including all necessary networking components.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 0: Generate SSH Key Pair](#step-0-generate-ssh-key-pair-for-linux-vms)
3. [Understanding the Architecture](#understanding-the-architecture)
4. [Step 1: Provider Configuration](#step-1-provider-configuration)
5. [Step 2: Resource Group](#step-2-resource-group)
6. [Step 3: Virtual Network](#step-3-virtual-network)
7. [Step 4: Subnet](#step-4-subnet)
8. [Step 5: Public IP Address](#step-5-public-ip-address)
9. [Step 6: Network Security Group](#step-6-network-security-group)
10. [Step 7: Network Interface](#step-7-network-interface)
11. [Step 8: Virtual Machine](#step-8-virtual-machine)
12. [Step 9: Variables Configuration](#step-9-variables-configuration)
13. [Step 10: Outputs](#step-10-outputs)
14. [Step 11: Deployment](#step-11-deployment)
15. [Complete Example Files](#complete-example-files)

---

## Prerequisites

Before starting, ensure you have:
- Terraform installed (version >= 1.5.0)
- Azure CLI installed and configured
- An Azure subscription
- Authenticated to Azure (`az login --use-device-code`)
- SSH key pair generated (for Linux VMs) - see section below

---

## Step 0: Generate SSH Key Pair (For Linux VMs)

SSH (Secure Shell) keys are used to securely authenticate to Linux virtual machines without using passwords. You'll need to generate an SSH key pair before creating a Linux VM.

### What is an SSH Key Pair?

An SSH key pair consists of two files:
- **Private Key** (`id_rsa`): Keep this secret! Never share it. Stays on your local machine.
- **Public Key** (`id_rsa.pub`): Can be shared freely. This is what you'll add to your Azure VM.

**How it works:**
1. You generate a key pair on your local machine
2. The public key is added to the VM during creation
3. When you SSH to the VM, your private key authenticates you
4. Much more secure than passwords!

### Check if You Already Have SSH Keys

First, check if you already have SSH keys:

```bash
ls -la ~/.ssh/id_rsa*
```

**If you see files like `id_rsa` and `id_rsa.pub`:**
- You already have SSH keys! Skip to the next section.
- You can use your existing public key: `~/.ssh/id_rsa.pub`

**If you get "No such file or directory":**
- You need to generate new SSH keys (follow steps below)

### Generate New SSH Key Pair

#### Step 1: Generate the Key Pair

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

**Breaking down the command:**
- `ssh-keygen`: Command to generate SSH keys
- `-t rsa`: Type of key (RSA algorithm)
- `-b 4096`: Key size in bits (4096 is secure, default is 2048)
- `-C "your_email@example.com"`: Comment/label (usually your email)

**What happens:**
1. You'll be prompted: `Enter file in which to save the key (/home/username/.ssh/id_rsa):`
   - Press **Enter** to accept the default location (`~/.ssh/id_rsa`)

2. You'll be prompted: `Enter passphrase (empty for no passphrase):`
   - **Option 1**: Press Enter twice for no passphrase (easier, but less secure)
   - **Option 2**: Enter a passphrase for extra security (recommended for production)
   - If you use a passphrase, you'll need to enter it each time you use the key

3. You'll be prompted: `Enter same passphrase again:`
   - Enter the same passphrase again (or press Enter if no passphrase)

**Expected Output:**
```
Generating public/private rsa key pair.
Your identification has been saved in /home/username/.ssh/id_rsa
Your public key has been saved in /home/username/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:AbCdEf1234567890... your_email@example.com
The key's randomart image is:
+---[RSA 4096]----+
|      ...        |
|     . . .       |
|    . . . .      |
|   . . . . .     |
|  . . . . . .    |
+----[SHA256]-----+
```

#### Step 2: Verify Key Generation

Check that both files were created:

```bash
ls -la ~/.ssh/id_rsa*
```

**Expected Output:**
```
-rw------- 1 username username 3243 Jan 15 10:30 /home/username/.ssh/id_rsa
-rw-r--r-- 1 username username  743 Jan 15 10:30 /home/username/.ssh/id_rsa.pub
```

**File Permissions:**
- `id_rsa` (private key): `-rw-------` (600) - Only you can read/write
- `id_rsa.pub` (public key): `-rw-r--r--` (644) - You can read/write, others can read

**Important:** If permissions are wrong, fix them:
```bash
chmod 600 ~/.ssh/id_rsa      # Private key: read/write for owner only
chmod 644 ~/.ssh/id_rsa.pub  # Public key: readable by others
```

#### Step 3: View Your Public Key

You'll need to copy your public key content for Terraform:

```bash
cat ~/.ssh/id_rsa.pub
```

**Expected Output:**
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC...very long string... your_email@example.com
```

**This is what you'll use in Terraform!**

### Alternative: Generate with Specific Name

If you want to use a different name for your key (e.g., for different projects):

```bash
ssh-keygen -t rsa -b 4096 -C "azure-vm-key" -f ~/.ssh/azure_vm_key
```

This creates:
- Private key: `~/.ssh/azure_vm_key`
- Public key: `~/.ssh/azure_vm_key.pub`

Then update your Terraform variable:
```hcl
ssh_public_key_path = "~/.ssh/azure_vm_key.pub"
```

### Using Existing SSH Keys

If you already have SSH keys from GitHub, GitLab, or other services, you can reuse them:

```bash
# Check if you have existing keys
ls -la ~/.ssh/

# Common key names:
# - id_rsa / id_rsa.pub (RSA)
# - id_ed25519 / id_ed25519.pub (Ed25519, newer)
# - id_ecdsa / id_ecdsa.pub (ECDSA)
```

**Note:** Azure supports RSA, ECDSA, and Ed25519 keys. RSA is most commonly used.

### Security Best Practices

1. **Never share your private key** (`id_rsa`)
   - Keep it secure on your local machine
   - Never commit it to version control
   - Never send it via email or chat

2. **Use a passphrase** (optional but recommended)
   - Adds an extra layer of security
   - Required if your private key is compromised

3. **Use different keys for different purposes**
   - One key for Azure VMs
   - Another key for GitHub
   - Another key for production servers

4. **Rotate keys regularly**
   - Generate new keys periodically
   - Remove old keys from VMs

### Troubleshooting

**Issue: "Permission denied (publickey)" when SSHing**
- Check that your public key was added to the VM correctly
- Verify private key permissions: `chmod 600 ~/.ssh/id_rsa`
- Ensure you're using the correct username

**Issue: "ssh-keygen: command not found"**
- Install OpenSSH client:
  ```bash
  # Ubuntu/Debian
  sudo apt-get install openssh-client
  
  # RHEL/CentOS
  sudo yum install openssh-clients
  ```

**Issue: "Too many authentication failures"**
- Your SSH client might be trying multiple keys
- Specify the key explicitly:
  ```bash
  ssh -i ~/.ssh/id_rsa azureuser@<vm-ip>
  ```

### What's Next?

After generating your SSH key pair:
1. ✅ You have a private key: `~/.ssh/id_rsa` (keep secret!)
2. ✅ You have a public key: `~/.ssh/id_rsa.pub` (use in Terraform)
3. ✅ Set the path in Terraform: `ssh_public_key_path = "~/.ssh/id_rsa.pub"`
4. ✅ After VM creation, SSH using: `ssh azureuser@<vm-public-ip>`

**Pro Tip:** Test your SSH key works by adding it to a test VM or GitHub before using it in production!

---

## Understanding the Architecture

When creating a VM in Azure, you need several interconnected components:

```
┌─────────────────────────────────────────────────────────┐
│                  Resource Group                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Virtual Network (VNet)                    │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │         Subnet                                │ │  │
│  │  │  ┌────────────────────────────────────────┐  │ │  │
│  │  │  │  Network Interface (NIC)                │  │ │  │
│  │  │  │  ├─ Private IP (from subnet)           │  │ │  │
│  │  │  │  └─ Public IP (optional)                │  │ │  │
│  │  │  │                                          │  │ │  │
│  │  │  │  Network Security Group (NSG)            │  │ │  │
│  │  │  │  └─ Security Rules (SSH, HTTP, etc.)    │  │ │  │
│  │  │  └────────────────────────────────────────┘  │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Virtual Machine                          │  │
│  │  └─ Connected to NIC                             │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Component Dependencies:**
1. Resource Group → Contains everything
2. Virtual Network → Contains subnets
3. Subnet → Used by Network Interface
4. Public IP → Attached to Network Interface
5. Network Security Group → Controls traffic
6. Network Interface → Connects VM to network
7. Virtual Machine → Uses Network Interface

---

## Step 1: Provider Configuration

**File: `provider.tf`**

The provider block tells Terraform which cloud provider to use and how to authenticate.

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
```

**Explanation:**
- `required_version`: Ensures Terraform version compatibility
- `required_providers`: Specifies the Azure provider and version constraint (`~> 3.0` means >= 3.0 and < 4.0)
- `features`: Configures provider-specific behaviors
- Authentication happens via Azure CLI (`az login`) or environment variables

---

## Step 2: Resource Group

**File: `rg.tf`**

### What is a Resource Group?

A **Resource Group** is a fundamental container in Azure that logically groups related resources together. Think of it as a folder that holds all the components of your application or infrastructure project.

**Key Characteristics:**
- **Logical Container**: It doesn't physically store resources—it's an organizational boundary
- **Required**: Every Azure resource MUST belong to exactly one resource group
- **Lifecycle Management**: Deleting a resource group deletes ALL resources within it
- **Access Control**: Permissions can be assigned at the resource group level
- **Billing**: Resource groups help organize costs and billing
- **Location**: Resource groups have a location (region), but this is just metadata—resources inside can be in different regions

**Why Resource Groups Matter:**
1. **Organization**: Group related resources (e.g., all resources for "Production Web App")
2. **Management**: Apply policies, tags, and permissions to entire groups
3. **Lifecycle**: Deploy or delete entire applications as a unit
4. **Cost Tracking**: Organize billing by project, environment, or team
5. **Security**: Control access at the resource group level

**Example Use Cases:**
- **By Environment**: `prod-rg`, `dev-rg`, `staging-rg`
- **By Project**: `webapp-rg`, `database-rg`, `networking-rg`
- **By Team**: `team-alpha-rg`, `team-beta-rg`
- **By Application**: `ecommerce-rg`, `api-rg`, `frontend-rg`

### Creating the Resource Group

```hcl
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "Terraform-VM-Review"
    ManagedBy   = "Terraform"
  }
}
```

**Parameter Explanation:**

- **`name`**: 
  - Unique identifier for the resource group within your subscription
  - Must be unique within your subscription (not globally)
  - Naming rules:
    - 1-90 characters
    - Alphanumeric, underscores, parentheses, hyphens, periods
    - Cannot end with a period
  - Example: `vm-review-rg`, `my-project-rg`, `production-infrastructure`

- **`location`**: 
  - Azure region where the resource group metadata is stored
  - **Important**: This is NOT where resources are created—it's just metadata
  - Resources inside the resource group can be in different regions
  - Common values: `eastus`, `westus2`, `westeurope`, `northeurope`
  - Use the same region as your primary resources for consistency

- **`tags`**: 
  - Key-value pairs for organization and automation
  - Used for:
    - Cost allocation and reporting
    - Policy enforcement
    - Automation scripts
    - Resource organization
  - Tags are inherited by resources created in the resource group (in some cases)
  - Common tags: `Environment`, `Project`, `Owner`, `CostCenter`, `ManagedBy`

**Why it's needed:** 
- **Mandatory**: Azure requires every resource to belong to a resource group—you cannot create resources without one
- **First Step**: The resource group must exist before creating any resources inside it
- **Organization**: Provides logical grouping and management boundaries
- **Lifecycle**: Enables bulk operations (deploy, delete, move entire groups)

**Important Notes:**
- Resource groups are **free**—you only pay for resources inside them
- You can have up to **980 resource groups** per subscription
- Deleting a resource group is **permanent** and **cannot be undone**—all resources inside are deleted
- Resources can be **moved between resource groups** (with some limitations)
- Resource groups **cannot be nested**—they're flat containers

**Best Practices:**
1. Use consistent naming conventions (e.g., `{project}-{environment}-rg`)
2. Group resources that share the same lifecycle
3. Use tags for better organization and cost tracking
4. Don't create too many resource groups—balance organization with manageability
5. Consider using resource groups for different environments (dev, staging, prod)

---

## Step 3: Virtual Network

**File: `network.tf`**

A Virtual Network (VNet) is an isolated network in Azure. It defines the IP address space for your resources.

```hcl
resource "azurerm_virtual_network" "main" {
  name                = "${var.name_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
  }
}
```

**Explanation:**
- `name`: Name of the virtual network
- `address_space`: CIDR block defining the network range (10.0.0.0/16 = 65,536 IP addresses)
- `location`: Must match the resource group location
- `resource_group_name`: References the resource group created earlier

**Why it's needed:** VMs need to be connected to a network. The VNet provides the network boundary and IP address space.

**Common Address Spaces:**
- `10.0.0.0/16` - Large network (65,536 addresses)
- `172.16.0.0/16` - Medium network
- `192.168.0.0/16` - Small network

---

## Step 4: Subnet

**File: `network.tf` (continued)**

A Subnet segments the VNet into smaller networks. VMs are placed in subnets, not directly in VNets.

```hcl
resource "azurerm_subnet" "main" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  # Explicit dependency to ensure VNet is created first
  depends_on = [azurerm_virtual_network.main]
}
```

**Explanation:**
- `name`: Name of the subnet
- `resource_group_name`: Must match the VNet's resource group
- `virtual_network_name`: References the VNet created above (uses the VNet's name)
- `address_prefixes`: CIDR block within the VNet's address space (10.0.1.0/24 = 256 addresses)
- `depends_on`: Explicit dependency to ensure VNet is created before subnet (prevents timing issues)

**Why it's needed:** Subnets allow you to organize and isolate resources. You can have multiple subnets in one VNet (e.g., frontend, backend, database).

**Important:** 
- The subnet's address space must be within the VNet's address space!
- Terraform should automatically detect dependencies, but `depends_on` ensures proper ordering

---

## Step 5: Public IP Address

**File: `network.tf` (continued)**

A Public IP allows your VM to be accessible from the internet. Without it, the VM is only accessible within the VNet.

```hcl
resource "azurerm_public_ip" "main" {
  name                = "${var.name_prefix}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"  # or "Dynamic"
  sku                 = "Basic"    # or "Standard"
}
```

**Explanation:**
- `name`: Name of the public IP resource
- `allocation_method`: 
  - `"Static"`: IP address doesn't change (recommended for production)
  - `"Dynamic"`: IP address can change when VM is stopped/deallocated
- `sku`: 
  - `"Basic"`: Free tier, fewer features, **has quota limits per subscription**
  - `"Standard"`: More features, costs more, higher quotas

**Why it's needed:** To SSH into your VM from your local machine, you need a public IP address.

**Security Note:** Public IPs expose your VM to the internet. Always use Network Security Groups to restrict access!

**⚠️ Important: Basic SKU Quota Limitation**

Azure subscriptions have **quota limits** for Basic SKU public IP addresses (often 0-5 per region). If you get this error:

```
IPv4BasicSkuPublicIpCountLimitReached: Cannot create more than 0 IPv4 Basic SKU public IP addresses
```

**Solutions:**

1. **Delete unused Basic public IPs** (Quickest fix):
   ```bash
   # List all public IPs in your subscription
   az network public-ip list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, SKU:sku.name}" -o table
   
   # Delete unused public IPs
   az network public-ip delete --name <public-ip-name> --resource-group <resource-group-name>
   ```

2. **Switch to Standard SKU** (Recommended for production):
   - Change `sku = "Basic"` to `sku = "Standard"`
   - **Note**: Standard SKU requires Standard VM size and Standard NIC (see below)

3. **Request quota increase** (Takes time):
   - Azure Portal → Subscriptions → Your Subscription → Usage + quotas
   - Search for "Public IP addresses - Basic"
   - Request increase

**Standard SKU Requirements:**

If using Standard SKU, you must also use:
- Standard VM size (e.g., `Standard_B1s` → `Standard_B1s` is fine, but ensure VM supports Standard networking)
- Standard Network Interface (automatically handled by Terraform)

**Example with Standard SKU:**

```hcl
resource "azurerm_public_ip" "main" {
  name                = "${var.name_prefix}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"  # Changed to Standard
  
  tags = {
    Environment = var.environment
  }
}
```

---

## Step 6: Network Security Group

**File: `network.tf` (continued)**

A Network Security Group (NSG) acts as a firewall, controlling inbound and outbound traffic.

```hcl
resource "azurerm_network_security_group" "main" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow SSH (port 22) from anywhere
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"  # WARNING: Allows from anywhere!
    destination_address_prefix = "*"
  }

  # Allow HTTP (port 80) - optional for web servers
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
  }
}
```

**Explanation:**
- `name`: Name of the NSG
- `security_rule`: Defines firewall rules
  - `priority`: Lower numbers = higher priority (100-4096)
  - `direction`: "Inbound" or "Outbound"
  - `access`: "Allow" or "Deny"
  - `protocol`: "Tcp", "Udp", "Icmp", or "*"
  - `source_port_range`: Port on source (usually "*")
  - `destination_port_range`: Port on destination (22 for SSH, 80 for HTTP)
  - `source_address_prefix`: Where traffic comes from ("*" = anywhere, or specific IP/CIDR)

**Why it's needed:** By default, Azure blocks all inbound traffic. NSG rules allow specific traffic (like SSH) to reach your VM.

**Security Best Practice:** Instead of `source_address_prefix = "*"`, use your own IP address or a specific IP range!

---

## Step 7: Network Interface

**File: `network.tf` (continued)**

A Network Interface (NIC) connects the VM to the network. It combines the subnet, public IP, and NSG.

```hcl
resource "azurerm_network_interface" "main" {
  name                = "${var.name_prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"  # or "Static"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Associate NSG with the Network Interface
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
```

**Explanation:**
- `name`: Name of the network interface
- `ip_configuration`: Defines IP settings
  - `subnet_id`: Which subnet the NIC belongs to
  - `private_ip_address_allocation`: 
    - `"Dynamic"`: Azure assigns IP automatically
    - `"Static"`: You specify the IP
  - `public_ip_address_id`: Attaches the public IP to the NIC
- `azurerm_network_interface_security_group_association`: Links the NSG to the NIC

**Why it's needed:** VMs don't connect directly to networks. The NIC is the bridge between the VM and the network infrastructure.

**Alternative:** You can also associate NSG directly to the subnet instead of the NIC.

---

## Step 8: Virtual Machine

**File: `vm.tf`**

Finally, the Virtual Machine itself! This is where you define the VM size, OS image, and authentication.

### For Linux VM:

```hcl
resource "azurerm_linux_virtual_machine" "main" {
  name                  = "${var.name_prefix}-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.main.id]

  # Disable password authentication (use SSH keys instead)
  disable_password_authentication = true

  # SSH Key Authentication
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  # OS Disk Configuration
  os_disk {
    name                 = "${var.name_prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"  # or "Premium_LRS"
  }

  # Source Image (Ubuntu 22.04 LTS)
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = var.environment
  }
}
```

**Explanation:**
- `name`: Name of the VM
- `size`: VM size (e.g., "Standard_B1s" = 1 vCPU, 1GB RAM, cheapest)
- `admin_username`: Username for admin access
- `network_interface_ids`: List of NICs to attach (usually one)
- `disable_password_authentication`: For Linux, use SSH keys instead of passwords
- `admin_ssh_key`: SSH public key for Linux authentication
- `admin_password`: Password for Windows authentication
- `os_disk`: Configuration for the VM's disk
  - `caching`: "ReadWrite", "ReadOnly", or "None"
  - `storage_account_type`: "Standard_LRS" (cheaper) or "Premium_LRS" (faster)
- `source_image_reference`: Which OS image to use
  - `publisher`: Image publisher (Canonical, MicrosoftWindowsServer, etc.)
  - `offer`: Image offer name
  - `sku`: Specific image version
  - `version`: "latest" or specific version

**Why it's needed:** This is the actual compute resource that runs your applications.

**Common VM Sizes:**
- `Standard_B1s`: 1 vCPU, 1GB RAM (cheapest, good for testing)
- `Standard_B2s`: 2 vCPU, 4GB RAM
- `Standard_D2s_v3`: 2 vCPU, 8GB RAM (production)

**Finding Images:** Use Azure CLI: `az vm image list --publisher Canonical --offer UbuntuServer --all`

---

## Step 9: Variables Configuration

**File: `variables.tf`**

Variables make your configuration reusable and maintainable.

```hcl
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "vm-review-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "vm-review"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
  
  validation {
    condition     = length(var.admin_username) >= 3 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 3 and 20 characters."
  }
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "admin_password" {
  description = "Admin password for Windows VM"
  type        = string
  sensitive   = true
  default     = null
}
```

**Explanation:**
- `description`: Documents what the variable is for
- `type`: Type constraint (string, number, bool, list, map, object)
- `default`: Default value if not provided
- `validation`: Rules to validate input
- `sensitive`: Marks sensitive data (passwords) to hide in logs

**Why it's needed:** Variables make your code reusable and allow different configurations for different environments.

**File: `terraform.tfvars` (optional)**

Override defaults with specific values:

```hcl
resource_group_name = "my-vm-rg"
location           = "westus2"
name_prefix        = "myvm"
environment        = "dev"
vm_size            = "Standard_B2s"
admin_username     = "adminuser"
ssh_public_key_path = "~/.ssh/id_rsa.pub"
```

---

## Step 10: Outputs

**File: `output.tf`**

Outputs expose important information after deployment.

```hcl
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.main.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}
```

**Explanation:**
- `description`: Documents what the output contains
- `value`: The value to output (references resource attributes)

**Why it's needed:** Outputs make it easy to find important information like IP addresses without searching through Azure portal.

---

## Step 11: Deployment

Now that all files are created, deploy your infrastructure:

### 1. Initialize Terraform

```bash
terraform init
```

This downloads the Azure provider and sets up the backend.

### 2. Validate Configuration

```bash
terraform validate
```

Checks for syntax errors and configuration issues.

### 3. Plan Deployment

```bash
terraform plan
```

Shows what Terraform will create/modify/destroy. Review carefully!

### 4. Apply Configuration

```bash
terraform apply
```

Creates all resources. Type `yes` when prompted.

### 5. Connect to VM

After deployment, use the output to SSH:

```bash
ssh azureuser@<public_ip_from_output>
```

### 6. Destroy Resources (when done)

```bash
terraform destroy
```

Removes all created resources to avoid charges.

---

## Complete Example Files

### Directory Structure

```
.
├── provider.tf      # Provider configuration
├── backend.tf      # Backend configuration (optional)
├── variables.tf     # Variable definitions
├── rg.tf           # Resource group
├── network.tf      # VNet, Subnet, Public IP, NSG, NIC
├── vm.tf           # Virtual machine
├── output.tf       # Outputs
└── terraform.tfvars # Variable values (optional)
```

### Complete `network.tf` Example

```hcl
# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.name_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    Environment = var.environment
  }
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "${var.name_prefix}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Basic"
}

# Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = "${var.name_prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "${var.name_prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# NSG Association
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
```

---

## Key Concepts Summary

1. **Resource Group**: Container for all resources
2. **Virtual Network**: Defines network boundary and IP space
3. **Subnet**: Segments the VNet for organization
4. **Public IP**: Enables internet access to VM
5. **Network Security Group**: Firewall rules for traffic control
6. **Network Interface**: Connects VM to network infrastructure
7. **Virtual Machine**: The compute resource

## Common Issues and Solutions

### Issue: "ResourceNotFound: The Resource 'Microsoft.Network/virtualNetworks/...' was not found"

This error occurs when Terraform tries to create a subnet before the Virtual Network exists, or the VNet creation failed.

**Understanding the Error:**
- The subnet resource references a VNet that doesn't exist yet
- This can happen due to:
  - VNet creation failed silently
  - Timing/dependency issue
  - VNet was created in a different resource group
  - Previous failed deployment left resources in inconsistent state

**Solution 1: Add Explicit Dependency (Recommended)**

Add `depends_on` to your subnet resource:

```hcl
resource "azurerm_subnet" "main" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  # Explicit dependency to ensure VNet is created first
  depends_on = [azurerm_virtual_network.main]
}
```

**Solution 2: Check if VNet Exists**

Verify the VNet was created:

```bash
# List all VNets in the resource group
az network vnet list --resource-group vm-review-rg --output table

# Check specific VNet
az network vnet show --name vm-review-vnet --resource-group vm-review-rg
```

**Solution 3: Clean Up and Retry**

If previous deployment failed partially:

```bash
# Check what resources exist
az resource list --resource-group vm-review-rg --output table

# Delete the resource group completely (if safe to do so)
az group delete --name vm-review-rg --yes --no-wait

# Wait for deletion, then retry terraform apply
```

**Solution 4: Use Terraform Refresh**

If resources exist in Azure but not in state:

```bash
# Refresh state from Azure
terraform refresh

# Then retry apply
terraform apply
```

**Solution 5: Check Resource Group Location**

Ensure VNet and subnet are in the same resource group:

```bash
# Verify resource group exists
az group show --name vm-review-rg

# Check VNet location matches resource group
az network vnet show --name vm-review-vnet --resource-group vm-review-rg --query location
```

**Prevention:**
- Always use `depends_on` for resources that reference other resources
- Review `terraform plan` output before applying
- Use `terraform validate` to catch configuration errors early

### Issue: "Subnet address space not within VNet"
**Solution**: Ensure subnet CIDR (e.g., 10.0.1.0/24) is within VNet CIDR (e.g., 10.0.0.0/16)

### Issue: "Cannot SSH to VM"
**Solution**: 
- Check NSG allows port 22
- Verify public IP is attached
- Ensure SSH key is correct

### Issue: "Resource name already exists"
**Solution**: Azure resource names must be globally unique. Change the name prefix.

### Issue: "Quota exceeded"
**Solution**: Azure has limits on resources per subscription. Delete unused resources or request quota increase.

### Issue: "IPv4BasicSkuPublicIpCountLimitReached: Cannot create more than 0 IPv4 Basic SKU public IP addresses"

This error means you've reached your subscription's quota limit for Basic SKU public IP addresses in the current region.

**Understanding the Error:**
- Azure subscriptions have **per-region quotas** for Basic SKU public IPs
- Free/trial subscriptions often have **0 Basic public IP quota**
- Each region has separate quotas
- Standard SKU has much higher quotas (often 100+)

**Solution 1: Check and Delete Unused Public IPs (Quickest)**

```bash
# List all public IPs in your subscription
az network public-ip list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, SKU:sku.name, IP:ipAddress}" -o table

# Check which ones are not attached to any resource
az network public-ip list --query "[?ipConfiguration==null].{Name:name, ResourceGroup:resourceGroup}" -o table

# Delete an unused public IP
az network public-ip delete \
  --name <public-ip-name> \
  --resource-group <resource-group-name>
```

**Solution 2: Switch to Standard SKU (Recommended)**

Standard SKU has much higher quotas and is better for production. Update your configuration:

**File: `network.tf` - Update Public IP:**
```hcl
resource "azurerm_public_ip" "main" {
  name                = "${var.name_prefix}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"  # Changed from "Basic"
  
  tags = {
    Environment = var.environment
  }
}
```

**Important Notes:**
- Standard SKU costs slightly more than Basic (but still very affordable)
- Standard SKU works with all VM sizes
- Standard SKU provides better security features (default secure by default)
- No code changes needed for VM or NIC - Terraform handles compatibility

**Solution 3: Use a Different Region**

Basic SKU quotas are per-region. Try deploying to a different region:

```hcl
variable "location" {
  default = "westus2"  # Try a different region
}
```

**Solution 4: Request Quota Increase (Takes Time)**

1. Go to Azure Portal
2. Navigate to: Subscriptions → Your Subscription → Usage + quotas
3. Search for: "Public IP addresses - Basic"
4. Click "Request increase"
5. Fill out the form (may take 24-48 hours)

**Solution 5: Use Dynamic Allocation (Temporary Workaround)**

Dynamic IPs count toward the same quota, but you can try:
- Delete unused static IPs first
- Use Dynamic allocation (IP changes when VM stops)

**Quick Fix Script:**

```bash
#!/bin/bash
# cleanup-unused-public-ips.sh
# Lists and optionally deletes unused Basic public IPs

echo "Finding unused Basic public IPs..."
UNUSED_IPS=$(az network public-ip list \
  --query "[?sku.name=='Basic' && ipConfiguration==null].{Name:name, ResourceGroup:resourceGroup}" \
  -o tsv)

if [ -z "$UNUSED_IPS" ]; then
  echo "No unused Basic public IPs found."
else
  echo "Unused Basic public IPs:"
  echo "$UNUSED_IPS"
  echo ""
  read -p "Delete these IPs? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "$UNUSED_IPS" | while read name rg; do
      echo "Deleting $name in $rg..."
      az network public-ip delete --name "$name" --resource-group "$rg" --yes
    done
  fi
fi
```

**Prevention:**

1. **Always use Standard SKU** for new deployments (avoids quota issues)
2. **Clean up unused resources** regularly
3. **Use Terraform destroy** when done testing to free up resources
4. **Tag resources** for easier identification and cleanup

---

## Next Steps

- Add multiple VMs using `count` or `for_each`
- Create modules for reusable network/VM configurations
- Add data disks to VMs
- Configure VM extensions for bootstrapping
- Set up load balancers for high availability
- Implement backup and disaster recovery

---

## Additional Resources

- [Azure VM Documentation](https://docs.microsoft.com/azure/virtual-machines/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Networking Overview](https://docs.microsoft.com/azure/networking/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

