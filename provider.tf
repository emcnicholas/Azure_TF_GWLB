terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.89.0"
    }
    fmc = {
      source = "CiscoDevNet/fmc"
      version = ">=1.4.5"
    }
    cdo = {
      source = "CiscoDevNet/cdo"
      version = ">=0.7.2, <1.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "fmc" {
  is_cdfmc  = true
  cdo_token = var.cdo_token
  fmc_host  = var.cdFMC
  cdfmc_domain_uuid = var.cdfmc_domain_uuid
}

provider "cdo" {
  base_url  = var.cdo_base_url
  api_token = var.cdo_token
}