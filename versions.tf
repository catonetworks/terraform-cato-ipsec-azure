terraform {
  required_providers {
    cato = {
      source  = "catonetworks/cato"
      version = ">= 0.0.24"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.1.0"
    }
  }
  required_version = ">= 1.4"
}
