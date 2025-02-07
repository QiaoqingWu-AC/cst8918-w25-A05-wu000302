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

# Define a resource group
resource "azurerm_resource_group" "rg" {
  name = "${var.labelPrefix}-A05-RG"
  location = var.region
}

# Define a public IP address
resource "azurerm_public_ip" "webserver" {
  name = "${var.labelPrefix}-A05-PublicIP"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Dynamic"
}

# Define a virtual network
resource "azurerm_virtual_network" "vnet" {
  name = "${var.labelPrefix}-A05-VNet"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = [ "10.0.0.0/16" ]
}

# Define the subnet
resource "azurerm_subnet" "web_subnet" {
  name = "${var.labelPrefix}-A05-Subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.1.0/24" ]
}

# Define the network security group and rules
resource "azurerm_network_security_group" "web_nsg" {
  name = "${var.labelPrefix}-A05-NSG"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name = "AllowSSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "AllowHTTP"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

# Define the network interface (NIC)
resource "azurerm_network_interface" "web_nic" {
  name = "${var.labelPrefix}-A05-NIC"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name = "${var.labelPrefix}-A05-NicConfig"
    subnet_id = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webserver.id
  }
}

# Apply the security group to the NIC
resource "azurerm_network_interface_security_group_association" "web_nic_assoc" {
  network_interface_id = azurerm_network_interface.web_nic.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}
