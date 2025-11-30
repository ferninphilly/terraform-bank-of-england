# Use the VM module
module "vm" {
  source = "./modules/vm"
  
  name_prefix        = var.name_prefix
  resource_group_name = var.resource_group_name
  location           = var.location
  vm_size            = var.vm_size
  admin_username     = var.admin_username
  ssh_public_key_path = var.ssh_public_key_path
  tags               = var.tags
}

# Use the alerts module (depends on VM module)
module "vm_alerts" {
  source = "./modules/vm-alerts"
  count  = var.enable_alerts ? 1 : 0
  
  vm_id                  = module.vm.vm_id
  vm_name                = module.vm.vm_name
  resource_group_name    = module.vm.resource_group_name
  location               = module.vm.location
  name_prefix            = var.name_prefix
  alert_email            = var.alert_email
  cpu_threshold_percent  = var.cpu_threshold_percent
  memory_threshold_percent = var.memory_threshold_percent
}

