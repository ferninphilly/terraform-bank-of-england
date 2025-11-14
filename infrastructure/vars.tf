# variables.tf

variable "resource_group_name" {
  description = "Name for the Azure Resource Group."
  type        = string
  default     = "terraform-vm-lesson-rg"
}

variable "location" {
  description = "The Azure region to deploy resources to."
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "The size of the Virtual Machine."
  type        = string
  default     = "Standard_B1ls" # Smallest size for cost efficiency
}

variable "admin_username" {
  description = "The username for the SSH connection."
  type        = string
  default     = "azureuser"
}