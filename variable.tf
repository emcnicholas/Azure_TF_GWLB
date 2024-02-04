# Azure Region
variable "location" {
  default = "eastus"
}

## Number of zones for www
#variable "www_zones" {
#  default = 2
#}
#
## Number of www VMs per zone
#variable "www_per_zone" {
#  default = 2
#}
#
## Number of zones for FW
#variable "fw_zones" {
#  default = 2
#}
#
## Number of FWs per zone
#variable "fw_per_zone" {
#  default = 1
#}

# Cluster Prefix
#variable "cluster_prefix" {
#  default = "ftd-cluster"
#}

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
variable "cdo_token" {}

variable "cdFMC" {}

variable "cdfmc_domain_uuid" {}

variable "cdo_base_url" {}

variable "ftd_performance_tier" {
  default = "FTDv30"
}