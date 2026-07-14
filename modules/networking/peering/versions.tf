terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.0, < 1.0.0"
    }
  }
}
