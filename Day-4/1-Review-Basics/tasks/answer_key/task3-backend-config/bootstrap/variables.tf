variable "resource_group_name" {
  description = "Name of the resource group for Terraform state storage"
  type        = string
  default     = "tfstate-rg"
}

variable "location" {
  description = "Azure region for the storage account"
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

variable "storage_account_prefix" {
  description = "Prefix for storage account name (will have random suffix added)"
  type        = string
  default     = "tfstatestorage"
  
  validation {
    condition     = length(var.storage_account_prefix) >= 3 && length(var.storage_account_prefix) <= 20
    error_message = "Storage account prefix must be between 3 and 20 characters."
  }
}

variable "container_name" {
  description = "Name of the blob container for Terraform state"
  type        = string
  default     = "tfstate"
}

