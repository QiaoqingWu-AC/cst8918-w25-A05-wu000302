# Define configuration variables
variable "labelPrefix" {
  type = string
  description = "A prefix for all resources"
}

variable "region" {
  type = string
  default = "canadacentral"
  description = "Azure region where resources will be deployed"
}

variable "admin_username" {
  type = string
  default = "azureadmin"
  description = "Admin username for the VM"
}