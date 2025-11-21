# Call the VM with Ansible module
module "web_vm" {
  source = "./modules/vm-with-ansible"

  # Required variables
  name_prefix        = var.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location

  # Environment configuration
  environment = var.environment
  vm_size     = var.vm_size

  # VM configuration
  admin_username = var.admin_username

  # Network configuration
  vnet_address_space       = var.vnet_address_space
  subnet_address_prefixes  = var.subnet_address_prefixes

  # Ansible configuration
  enable_ansible        = var.enable_ansible
  ansible_playbook_path = var.ansible_playbook_path
  install_nginx        = var.install_nginx
  install_docker       = var.install_docker

  # Tags
  tags = merge(var.tags, {
    Module = var.module_tag_web_vm
  })
}

# VM Monitoring and Alerts Module
# This module creates alerts for the VM created above
module "web_vm_alerts" {
  source = "./modules/alerts"

  # VM information (from vm-with-ansible module)
  vm_id              = module.web_vm.vm_id
  vm_name            = module.web_vm.vm_name
  resource_group_name = azurerm_resource_group.main.name
  location           = var.location
  name_prefix        = var.name_prefix

  # Alert configuration
  enable_alerts          = var.enable_alerts
  alert_email            = var.alert_email
  cpu_threshold_percent  = var.cpu_threshold_percent
  memory_threshold_percent = var.memory_threshold_percent
  disk_threshold_percent = var.disk_threshold_percent
  disk_read_threshold    = var.disk_read_threshold
  disk_write_threshold   = var.disk_write_threshold
  network_in_threshold   = var.network_in_threshold
  environment            = var.environment

  tags = merge(var.tags, {
    Module = var.module_tag_alerts
  })

  # Depends on VM being created first
  depends_on = [module.web_vm]
}

# Example: Create a second VM with different configuration
# Uncomment to create multiple VMs with different settings
# module "app_vm" {
#   source = "./modules/vm-with-ansible"
#
#   name_prefix        = "app"
#   resource_group_name = azurerm_resource_group.main.name
#   location           = var.location
#   environment       = var.environment
#   vm_size           = "Standard_B2s"  # Override default
#   install_nginx     = false            # Don't install nginx
#   install_docker    = true             # Install Docker instead
#
#   tags = merge(var.tags, {
#     Module = "app-vm"
#   })
# }
#
# # Alerts for the second VM
# module "app_vm_alerts" {
#   source = "./modules/alerts"
#
#   vm_id              = module.app_vm.vm_id
#   vm_name            = module.app_vm.vm_name
#   resource_group_name = azurerm_resource_group.main.name
#   location           = var.location
#   name_prefix        = "app"
#   enable_alerts      = var.enable_alerts
#   alert_email        = var.alert_email
#
#   depends_on = [module.app_vm]
# }

