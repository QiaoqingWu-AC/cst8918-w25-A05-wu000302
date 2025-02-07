# Configure the Terraform runtime requirements
terraform {
  required_version = ">= 1.1.0"

  required_providers {
    # Azure resource manager provider and version
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.3"
    }
  }
}

# Define providers and their config params
provider "azurerm" {
  # leave the features block empty to accept all defaults
  features { }
}

provider "cloudinit" {
  # configuration options
}