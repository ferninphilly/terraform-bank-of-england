variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "cicd"
}

