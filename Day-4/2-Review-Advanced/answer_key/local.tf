# Naming Convention using String Functions
locals {
  # Convert project name to lowercase and replace spaces with hyphens
  normalized_project_name = lower(replace(var.project_name, " ", "-"))
  
  # Create name prefix: project-environment (e.g., "myproject-dev")
  name_prefix = "${local.normalized_project_name}-${var.environment}"
  
  # Resource naming using string functions
  resource_names = {
    resource_group = "${local.name_prefix}-rg"
    vnet           = "${local.name_prefix}-vnet"
    nsg            = "${local.name_prefix}-nsg"
  }
  
  # Common tags with string manipulation
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Location    = var.location
      Project     = local.normalized_project_name
    }
  )
  
  # Subnet names with prefix
  subnet_names = {
    for k, v in var.subnets : k => "${local.name_prefix}-${k}-subnet"
  }
  
  # Filter subnets that need NSG
  subnets_with_nsg = {
    for k, v in var.subnets : k => v
    if v.nsg_enabled == true
  }
}

