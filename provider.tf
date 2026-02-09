terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.59.0"
    }
    fmc = {
      source = "CiscoDevNet/fmc"
      version = "2.0.0"
    }
    sccfm = {
      source = "CiscoDevNet/sccfm"
      version = "0.3.2"
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
  cdo_token = var.api_token
  fmc_host  = var.cdFMC
  cdfmc_domain_uuid = var.cdfmc_domain_uuid
}

provider "sccfm" {
  base_url  = var.base_url
  api_token = var.api_token
}