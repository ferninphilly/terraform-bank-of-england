variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2",
      "westeurope", "northeurope"
    ], var.location)
    error_message = "Location must be in allowed regions."
  }
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}

