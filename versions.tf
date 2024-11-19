terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # version = "~> 4.1.0"
    }
    cato = {
      source  = "registry.terraform.io/catonetworks/cato"
      version = "~> 0.0.8"
    }
  }
}