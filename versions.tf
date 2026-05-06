terraform {
  required_providers {
    cato = {
      source  = "catonetworks/cato"
      version = ">= 0.0.70"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.71.0"
    }
  }
  required_version = ">= 1.5"
}
