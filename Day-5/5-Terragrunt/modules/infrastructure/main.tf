# TODO: Create infrastructure module
# This module will be called by Terragrunt configurations
# Include:
# - Resource group
# - Storage account
# - Virtual network
# - Virtual machines (based on instance_count)

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "VM size"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# TODO: Add resources here

