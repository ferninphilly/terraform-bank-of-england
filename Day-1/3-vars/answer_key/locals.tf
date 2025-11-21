locals {
  # Common tags used across all resources
  common_tags = {
    environment = "dev"
    lob         = "banking"
    stage       = "alpha"
  }

  # Resource prefix for naming
  resource_prefix = "boe"
}

