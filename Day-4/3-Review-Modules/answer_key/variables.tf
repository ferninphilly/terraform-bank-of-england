variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "myproject-rg"
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "MyProject"
    ManagedBy   = "Terraform"
  }
}

