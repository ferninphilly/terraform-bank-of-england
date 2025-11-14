variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-test-example"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
  default     = "teststorageaccount"
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "create_vnet" {
  description = "Whether to create a virtual network"
  type        = bool
  default     = true
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-test-example"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

