variable "subscription_id" {
  type        = string
  description = "The subscription ID to use for the Azure resources"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
  default     = "vm-resources"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "West Europe"
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine"
  default     = "my-first-vm"
}

variable "vm_size" {
  type        = string
  description = "Size of the virtual machine (e.g., Standard_B1s, Standard_B2s)"
  default     = "Standard_B1s"
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the VM"
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM authentication"
  sensitive   = true
}

