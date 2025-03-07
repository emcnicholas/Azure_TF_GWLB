terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.18.0"
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
  #resource_provider_registrations = "none"
  subscription_id = "61b020af-0c48-4132-b2cf-2b162c4c42a2"
  features {}
  skip_provider_registration = true # Prevents registering varying resource providers, which may be either deprecated, unavailable, or invalid in the Azure subscription you're using.
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