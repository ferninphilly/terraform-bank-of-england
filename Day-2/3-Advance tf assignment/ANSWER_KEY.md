# 🔑 Answer Key: Advanced Azure Infrastructure with Terraform

This document provides step-by-step instructions for completing the advanced Terraform assignment. Follow these steps to build a scalable web application infrastructure with VMSS, load balancer, and auto-scaling.

## 📚 Prerequisites

- Terraform installed (>= 1.9.0)
- Azure CLI configured
- Azure subscription with appropriate permissions
- SSH key pair generated (for VMSS access)

---

## 📝 Step 1: Create Variables File

### Step 1.1: Create `variables.tf`

Create a file named `variables.tf` with the following content:

```terraform
# Environment variable
variable "environment" {
  type        = string
  description = "Environment name (dev, stage, prod)"
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}

# Region variable with validation
variable "region" {
  type        = string
  description = "Azure region for deployment"
  default     = "West Europe"
  
  validation {
    condition = contains([
      "West Europe",
      "Western Europe",
      "Southeast Asia"
    ], var.region)
    error_message = "Region must be one of: West Europe, Western Europe, or Southeast Asia."
  }
}

# Resource name prefix
variable "resource_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "vmss-app"
  
  validation {
    condition     = length(var.resource_prefix) >= 3 && length(var.resource_prefix) <= 15
    error_message = "Resource prefix must be between 3 and 15 characters."
  }
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_prefix))
    error_message = "Resource prefix can only contain lowercase letters, numbers, and hyphens."
  }
}

# Instance counts
variable "min_instances" {
  type        = number
  description = "Minimum number of VM instances"
  default     = 2
}

variable "max_instances" {
  type        = number
  description = "Maximum number of VM instances"
  default     = 5
}

variable "default_instances" {
  type        = number
  description = "Default number of VM instances"
  default     = 2
}

# Network address spaces
variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
  default     = ["10.0.0.0/16"]
}

variable "app_subnet_address_prefix" {
  type        = string
  description = "Address prefix for application subnet"
  default     = "10.0.1.0/24"
}

variable "mgmt_subnet_address_prefix" {
  type        = string
  description = "Address prefix for management subnet"
  default     = "10.0.2.0/24"
}
```

---

## 📝 Step 2: Create Terraform Variables File

### Step 2.1: Create `terraform.tfvars`

Create a file named `terraform.tfvars` with your configuration:

```hcl
environment   = "dev"
region        = "West Europe"
resource_prefix = "vmss-app"

min_instances  = 2
max_instances  = 5
default_instances = 2

vnet_address_space         = ["10.0.0.0/16"]
app_subnet_address_prefix  = "10.0.1.0/24"
mgmt_subnet_address_prefix = "10.0.2.0/24"
```

---

## 📝 Step 3: Create Locals Block

### Step 3.1: Create `locals.tf`

Create a file named `locals.tf` with common tags, naming conventions, and network configuration:

```terraform
locals {
  # Common tags
  common_tags = {
    Environment   = var.environment
    ManagedBy     = "Terraform"
    Project       = "VMSS-WebApp"
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
  }
  
  # Resource naming convention
  resource_group_name = "${var.resource_prefix}-${var.environment}-rg"
  vnet_name           = "${var.resource_prefix}-${var.environment}-vnet"
  app_subnet_name     = "${var.resource_prefix}-${var.environment}-app-subnet"
  mgmt_subnet_name    = "${var.resource_prefix}-${var.environment}-mgmt-subnet"
  nsg_name            = "${var.resource_prefix}-${var.environment}-nsg"
  vmss_name           = "${var.resource_prefix}-${var.environment}-vmss"
  lb_name             = "${var.resource_prefix}-${var.environment}-lb"
  lb_public_ip_name   = "${var.resource_prefix}-${var.environment}-lb-pip"
  
  # Network configuration
  network_config = {
    vnet_address_space = var.vnet_address_space
    app_subnet         = var.app_subnet_address_prefix
    mgmt_subnet        = var.mgmt_subnet_address_prefix
  }
  
  # VM size lookup based on environment
  vm_sizes = {
    dev   = "Standard_B1s"
    stage = "Standard_B2s"
    prod  = "Standard_B2ms"
  }
  
  # Get VM size for current environment
  vm_size = lookup(local.vm_sizes, var.environment, "Standard_B1s")
  
  # NSG rules configuration (for dynamic blocks)
  nsg_rules = [
    {
      name                       = "AllowHTTPFromLB"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Allow HTTP traffic from Load Balancer"
    },
    {
      name                       = "AllowHTTPSFromLB"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Allow HTTPS traffic from Load Balancer"
    }
  ]
  
  # Load balancer rules configuration (for dynamic blocks)
  lb_rules = [
    {
      name      = "HTTP"
      protocol  = "Tcp"
      frontend_port = 80
      backend_port  = 80
      probe_name    = "http-probe"
    }
  ]
}
```

---

## 📝 Step 4: Create Provider Configuration

### Step 4.1: Create `provider.tf`

Create or update `provider.tf`:

```terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8.0"
    }
  }
  required_version = ">= 1.9.0"
}

provider "azurerm" {
  features {}
}
```

---

## 📝 Step 5: Create Resource Group

### Step 5.1: Create `rg.tf`

Create a file named `rg.tf`:

```terraform
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.region
  
  tags = local.common_tags
}
```

**Key Points:**
- Uses `local.resource_group_name` for consistent naming
- Uses `var.region` which is validated
- Applies common tags

---

## 📝 Step 6: Create Virtual Network and Subnets

### Step 6.1: Create `vnet.tf`

Create a file named `vnet.tf`:

```terraform
# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = local.network_config.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  tags = local.common_tags
}

# Application Subnet (for VMSS)
resource "azurerm_subnet" "app_subnet" {
  name                 = local.app_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.network_config.app_subnet]
}

# Management Subnet (for future use)
resource "azurerm_subnet" "mgmt_subnet" {
  name                 = local.mgmt_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.network_config.mgmt_subnet]
}
```

**Key Points:**
- Two subnets as required: application and management
- Uses locals for naming and configuration
- Address prefixes from variables

---

## 📝 Step 7: Create Network Security Group with Dynamic Blocks

### Step 7.1: Update `vnet.tf` - Add NSG

Add the NSG resource to `vnet.tf`:

```terraform
# Network Security Group with dynamic rules
resource "azurerm_network_security_group" "nsg" {
  name                = local.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  # Dynamic block for security rules
  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }
  
  tags = local.common_tags
}

# Associate NSG with Application Subnet
resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
```

**Key Points:**
- Uses `dynamic "security_rule"` block
- Rules only allow traffic from `AzureLoadBalancer` (not from Internet)
- Denies all other inbound traffic by default (Azure default behavior)
- Associated with application subnet only

---

## 📝 Step 8: Create Load Balancer

### Step 8.1: Create `loadbalancer.tf`

Create a file named `loadbalancer.tf`:

```terraform
# Public IP for Load Balancer
resource "azurerm_public_ip" "lb_pip" {
  name                = local.lb_public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = local.common_tags
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = local.lb_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
  
  tags = local.common_tags
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "${local.lb_name}-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

# Health Probe
resource "azurerm_lb_probe" "http_probe" {
  name            = "http-probe"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
  interval_in_seconds = 5
  number_of_probes  = 2
}

# Load Balancer Rules (using dynamic block)
resource "azurerm_lb_rule" "lb_rules" {
  for_each = { for rule in local.lb_rules : rule.name => rule }
  
  name                           = each.value.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
}
```

**Key Points:**
- Public IP with Static allocation
- Standard SKU load balancer
- Health probe on port 80
- Dynamic block for load balancer rules
- Backend pool connected to VMSS (will be done in VMSS config)

---

## 📝 Step 9: Create Virtual Machine Scale Set

### Step 9.1: Create `vmss.tf`

Create a file named `vmss.tf`:

```terraform
# Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = local.vmss_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = local.vm_size  # Uses lookup based on environment
  instances           = var.default_instances
  admin_username      = "azureuser"
  
  # Disable password authentication
  disable_password_authentication = true
  
  # SSH Key configuration
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Update path to your SSH public key
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
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  # Network Interface Configuration
  network_interface {
    name    = "vmss-nic"
    primary = true
    
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.app_subnet.id
      
      # Connect to Load Balancer Backend Pool
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.backend_pool.id
      ]
    }
  }
  
  # Custom Data (startup script)
  custom_data = base64encode(templatefile("${path.module}/user-data.sh", {
    # You can pass variables to the script if needed
  }))
  
  # Lifecycle to ignore instance count changes (managed by autoscale)
  lifecycle {
    ignore_changes = [instances]
  }
  
  tags = local.common_tags
}
```

**Key Points:**
- Uses `local.vm_size` which is looked up based on environment
- VM sizes: Dev=Standard_B1s, Stage=Standard_B2s, Prod=Standard_B2ms
- Connected to application subnet
- Connected to load balancer backend pool
- Uses custom data script for initialization
- Ignores instance count changes (managed by autoscale)

---

## 📝 Step 10: Create User Data Script

### Step 10.1: Create `user-data.sh`

Create a file named `user-data.sh`:

```bash
#!/bin/bash
# Update system
apt-get update -y

# Install Apache and PHP
apt-get install -y apache2 php php-curl libapache2-mod-php php-mysql

# Configure firewall
ufw allow 'Apache Full'

# Create web directory
mkdir -p /var/www/html
chown -R azureuser:azureuser /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# Create a simple index page
cd /var/www/html
cat > index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>VMSS Instance</title>
</head>
<body>
    <h1>Hello from VMSS!</h1>
    <p>Instance ID: $(hostname)</p>
    <p>This is a load-balanced web server.</p>
</body>
</html>
EOF

# Start Apache
systemctl enable apache2
systemctl start apache2
```

**Key Points:**
- Installs Apache web server
- Creates a simple HTML page
- Configures permissions
- Starts Apache service

---

## 📝 Step 11: Create Auto-Scaling Configuration

### Step 11.1: Create `autoscale.tf`

Create a file named `autoscale.tf`:

```terraform
# Auto-Scaling Settings
resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "${local.vmss_name}-autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id
  enabled             = true
  
  profile {
    name = "default"
    
    capacity {
      default = var.default_instances
      minimum = var.min_instances
      maximum = var.max_instances
    }
    
    # Scale out rule (when CPU > 80%)
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        dimensions {
          name     = "VMName"
          operator = "Equals"
          values   = ["*"]
        }
      }
      
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    
    # Scale in rule (when CPU < 10%)
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT2M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        dimensions {
          name     = "VMName"
          operator = "Equals"
          values   = ["*"]
        }
      }
      
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
  
  notification {
    email {
      send_to_subscription_administrator    = false
      send_to_subscription_co_administrator = false
      custom_emails                         = []  # Add email addresses if needed
    }
  }
}
```

**Key Points:**
- Minimum instances: 2
- Maximum instances: 5
- Scale out when CPU > 80% for 5 minutes
- Scale in when CPU < 10% for 2 minutes
- Cooldown period of 1 minute between scaling actions

---

## 📝 Step 12: Create Outputs

### Step 12.1: Create `outputs.tf`

Create a file named `outputs.tf`:

```terraform
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "load_balancer_fqdn" {
  description = "Fully qualified domain name of the load balancer"
  value       = azurerm_public_ip.lb_pip.fqdn
}

output "vmss_name" {
  description = "Name of the Virtual Machine Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "vm_size" {
  description = "VM size used in the scale set"
  value       = local.vm_size
}

output "current_instances" {
  description = "Current number of VM instances"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.instances
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "app_subnet_id" {
  description = "ID of the application subnet"
  value       = azurerm_subnet.app_subnet.id
}
```

---

## 📝 Step 13: Deploy the Infrastructure

### Step 13.1: Initialize Terraform

```bash
terraform init
```

### Step 13.2: Review the Plan

```bash
terraform plan
```

**Verify:**
- Resource group with correct region
- VNet with two subnets
- NSG with dynamic rules
- Load balancer with public IP
- VMSS with correct VM size for environment
- Auto-scaling configuration

### Step 13.3: Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted.

**Wait for completion** (this may take 10-15 minutes)

### Step 13.4: Verify Deployment

1. **Get the load balancer IP:**
   ```bash
   terraform output load_balancer_public_ip
   ```

2. **Test the web server:**
   ```bash
   curl http://$(terraform output -raw load_balancer_public_ip)
   ```

3. **Check VMSS instances in Azure Portal:**
   - Navigate to your resource group
   - Find the VMSS resource
   - Check "Instances" tab
   - Should show 2 instances (minimum)

---

## 📝 Step 14: Test Auto-Scaling

### Step 14.1: Generate Load to Trigger Scale-Out

You can use a tool like `ab` (Apache Bench) or `curl` in a loop:

```bash
# Install Apache Bench (if not installed)
# On macOS: brew install httpd
# On Linux: sudo apt-get install apache2-utils

# Generate load
ab -n 10000 -c 100 http://$(terraform output -raw load_balancer_public_ip)/
```

### Step 14.2: Monitor Scaling

1. **Check Azure Portal:**
   - Go to VMSS → Monitoring → Metrics
   - Add "Percentage CPU" metric
   - Watch for scale-out events

2. **Check instance count:**
   ```bash
   az vmss list-instances \
     --resource-group $(terraform output -raw resource_group_name) \
     --name $(terraform output -raw vmss_name) \
     --output table
   ```

---

## 📊 Complete File Structure

Your project should have:

```
Day-2/3-Advance tf assignment/
├── provider.tf          # Provider configuration
├── variables.tf          # Variable definitions
├── terraform.tfvars     # Variable values
├── locals.tf             # Local values and computed data
├── rg.tf                 # Resource group
├── vnet.tf               # Virtual network and subnets
├── loadbalancer.tf       # Load balancer configuration
├── vmss.tf               # Virtual Machine Scale Set
├── autoscale.tf          # Auto-scaling settings
├── user-data.sh          # VM initialization script
├── outputs.tf            # Output definitions
├── backend.tf            # Backend configuration (optional)
├── readme.md             # Assignment requirements
└── ANSWER_KEY.md         # This file
```

---

## ✅ Verification Checklist

Before completing, verify:

- [ ] Resource group created in allowed region
- [ ] Region validation works (try invalid region)
- [ ] VNet with two subnets (app and mgmt)
- [ ] NSG with dynamic rules allowing only LB traffic
- [ ] VMSS created with correct VM size for environment
- [ ] VMSS connected to load balancer backend pool
- [ ] Load balancer has public IP and health probe
- [ ] Auto-scaling configured (min 2, max 5)
- [ ] Scale-out rule: CPU > 80% for 5 minutes
- [ ] Scale-in rule: CPU < 10% for 2 minutes
- [ ] All resources have consistent naming
- [ ] All resources have tags
- [ ] Variables file created with all required values
- [ ] Locals block implements naming and tags
- [ ] Dynamic blocks used for NSG and LB rules

---

## 🎓 Key Concepts Demonstrated

1. **Variable Validation:**
   - Region restriction
   - Environment validation
   - Resource prefix validation

2. **Locals for Organization:**
   - Common tags
   - Naming conventions
   - Network configuration
   - VM size lookup

3. **Dynamic Blocks:**
   - NSG rules from list
   - Load balancer rules from map

4. **Lookup Function:**
   - Environment-based VM sizing

5. **Auto-Scaling:**
   - CPU-based scaling rules
   - Min/max instance limits

---

## 🐛 Troubleshooting

### Issue: Region Validation Fails

**Solution:**
- Check exact region name spelling
- Use one of: "West Europe", "Western Europe", "Southeast Asia"

### Issue: VMSS Not Scaling

**Solution:**
- Check autoscale settings are enabled
- Verify metrics are being collected
- Ensure cooldown period has passed
- Check VMSS has proper monitoring extension

### Issue: Load Balancer Health Probe Failing

**Solution:**
- Verify Apache is running on VMs
- Check NSG allows traffic from AzureLoadBalancer
- Verify health probe path is correct (/)
- Check VMSS instances are in backend pool

### Issue: Cannot Access Load Balancer IP

**Solution:**
- Verify NSG rules allow traffic from Load Balancer
- Check health probe is passing
- Ensure VMSS instances are running
- Verify load balancer rule is configured correctly

---

## 📚 Additional Resources

- [Azure VMSS Documentation](https://docs.microsoft.com/azure/virtual-machine-scale-sets/)
- [Azure Load Balancer](https://docs.microsoft.com/azure/load-balancer/)
- [Azure Auto-Scaling](https://docs.microsoft.com/azure/azure-monitor/autoscale/autoscale-overview)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

## 🎉 Congratulations!

You've successfully created a production-ready, scalable infrastructure with:
- ✅ Validated resource group
- ✅ Multi-subnet network
- ✅ Secure NSG with dynamic rules
- ✅ Environment-based VM sizing
- ✅ Load-balanced VMSS
- ✅ Auto-scaling configuration

This infrastructure is ready for production workloads!

