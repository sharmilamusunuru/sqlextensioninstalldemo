terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "sql_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "sql_vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sql_rg.location
  resource_group_name = azurerm_resource_group.sql_rg.name
}

# Subnet
resource "azurerm_subnet" "sql_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.sql_rg.name
  virtual_network_name = azurerm_virtual_network.sql_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "sql_public_ip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.sql_rg.location
  resource_group_name = azurerm_resource_group.sql_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Security Group
resource "azurerm_network_security_group" "sql_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.sql_rg.location
  resource_group_name = azurerm_resource_group.sql_rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SQL"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "sql_nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.sql_rg.location
  resource_group_name = azurerm_resource_group.sql_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sql_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sql_public_ip.id
  }
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "sql_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.sql_nic.id
  network_security_group_id = azurerm_network_security_group.sql_nsg.id
}

# Windows Virtual Machine for SQL Server
resource "azurerm_windows_virtual_machine" "sql_vm" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.sql_rg.name
  location            = azurerm_resource_group.sql_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.sql_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = var.sql_server_offer
    sku       = var.sql_server_sku
    version   = "latest"
  }
}

# SQL Virtual Machine with SQL IaaS Agent Extension
resource "azurerm_mssql_virtual_machine" "sql_iaas" {
  virtual_machine_id               = azurerm_windows_virtual_machine.sql_vm.id
  sql_license_type                 = var.sql_license_type
  r_services_enabled               = false
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PUBLIC"
  sql_connectivity_update_password = var.admin_password
  sql_connectivity_update_username = var.admin_username

  auto_patching {
    day_of_week                            = var.auto_patching_day_of_week
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }

  auto_backup {
    retention_period_in_days        = 30
    storage_blob_endpoint           = azurerm_storage_account.sql_storage.primary_blob_endpoint
    storage_account_access_key      = azurerm_storage_account.sql_storage.primary_access_key
    system_databases_backup_enabled = true
    encryption_enabled              = true
    encryption_password             = var.admin_password
  }
}

# Storage Account for SQL backups
resource "azurerm_storage_account" "sql_storage" {
  name                     = "${var.prefix}sqlstorage${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.sql_rg.name
  location                 = azurerm_resource_group.sql_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Random string for storage account name uniqueness
resource "random_string" "storage_suffix" {
  length  = 6
  special = false
  upper   = false
}
