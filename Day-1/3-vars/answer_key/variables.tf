variable "subscription_id" {
  type        = string
  description = "The subscription ID to use for the Azure resources"
  default     = ""
}

variable "environment" {
  type        = string
  description = "The environment type (dev, staging, production)"
  default     = "staging"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
  default     = "West Europe"
}

