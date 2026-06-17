terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.56"
    }
  }
}

provider "azurerm" {
  features {}
  
  resource_provider_registrations = "none"
}

# Subnet
resource "azurerm_subnet" "ynov1-subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.ynov1-rg.name
  virtual_network_name = azurerm_virtual_network.ynov1-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IPs
resource "azurerm_public_ip" "ynov1-ip" {
  name                = "${var.prefix}-ip"
  location            = azurerm_resource_group.ynov1-rg.location
  resource_group_name = azurerm_resource_group.ynov1-rg.name
  allocation_method   = "Static"

  tags = {
    environment = "${var.environment}"
    owner       = "${var.prefix}"
    label       = "Public IP"
    project     = "${var.project}"
  }
}

output "public_ip" {
  value = azurerm_public_ip.ynov1-ip.ip_address
}

# Resource Group
resource "azurerm_resource_group" "ynov1-rg" {
  name     = "${var.prefix}-resources"
  location = "Sweden Central"

  tags = {
    environment = "${var.environment}"
    owner       = "${var.prefix}"
    label       = "Resource Group"
    project     = "${var.project}"
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "ynov1-vm" {
  name                = "${var.prefix}-vm"
  location            = azurerm_resource_group.ynov1-rg.location
  resource_group_name = azurerm_resource_group.ynov1-rg.name
  network_interface_ids = [
    azurerm_network_interface.ynov1-nic.id
  ]
  size           = "Standard_B2ts_v2"
  admin_username = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "${var.environment}"
    owner       = "${var.prefix}"
    label       = "Virtual Machine"
    project     = "${var.project}"
  }

  allow_extension_operations=false
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.ynov1-vm.name
}

# Virtual Network
resource "azurerm_virtual_network" "ynov1-vnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ynov1-rg.location
  resource_group_name = azurerm_resource_group.ynov1-rg.name

  tags = {
    environment = "${var.environment}"
    owner       = "${var.prefix}"
    label       = "Virtual Network"
    project     = "${var.project}"
  }
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "ynov1-rg" {
  name                     = "ynov1rg${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.ynov1-rg.name
  location                 = azurerm_resource_group.ynov1-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "ynov1-rg" {
  name                  = "ehusser"
  storage_account_id    = azurerm_storage_account.ynov1-rg.id
  container_access_type = "private"
}

# Network Security Group and rule
resource "azurerm_network_security_group" "ynov1-nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.ynov1-rg.location
  resource_group_name = azurerm_resource_group.ynov1-rg.name

  # Allow incoming connection on port 22 for SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "${var.environment}"
    owner       = "${var.prefix}"
    label       = "Network Security Group"
    project     = "${var.project}"
  }
}

# Network Interface
resource "azurerm_network_interface" "ynov1-nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.ynov1-rg.location
  resource_group_name = azurerm_resource_group.ynov1-rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.ynov1-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ynov1-ip.id
  }

  tags = {
    environment = "${var.environment}"
    owner       = "${var.prefix}"
    label       = "Network Interface"
    project     = "${var.project}"
  }
}

# Associate Network Security group with Subnet
resource "azurerm_subnet_network_security_group_association" "nsg-subnet" {
  subnet_id                 = azurerm_subnet.ynov1-subnet.id
  network_security_group_id = azurerm_network_security_group.ynov1-nsg.id
}
