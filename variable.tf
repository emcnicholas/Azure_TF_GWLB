# Azure Region
variable "location" {
  default = "eastus"
}

# Source IP address where ssh connection to the bastian host would initiate.
variable "ssh_sources" {
  default = ["173.75.255.105/32"]
}


# Admin Password
variable "admin_password" {
}

# Key Pair Name
variable "name" {
}

# CDO
variable "api_token" {}

variable "cdFMC" {}

variable "cdfmc_domain_uuid" {}

variable "base_url" {}

variable "ftd_performance_tier" {
  default = "FTDv30"
}