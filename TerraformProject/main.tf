terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.71.0"
    }
  }
}

provider "azurerm" {

subscription_id = "b8cb3ebc-47d3-48e5-beee-f643e634d439"
  client_id       = "9bd91b9b-c31d-4804-93f1-450556a73c8b"
  client_secret   = "KBA8Q~KVRX9AjPVCPG6EBTYhSWCKEoL7ad~iOa8L"
  tenant_id       = "c687f5df-c635-4c81-a6bc-06575450ebcf"
  features {}
}

resource "azurerm_resource_group" "app_grp" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.app_grp.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "data" {
  name                 = "data"
  storage_account_name = azurerm_storage_account.storage_account.name
  depends_on = [
    azurerm_storage_account.storage_account
  ]
}

resource "azurerm_virtual_network" "app_network" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = var.subnet_name
    address_prefix = "10.0.1.0/24"
  }
}

data "azurerm_subnet" "SubnetA" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.app_network.name
  resource_group_name  = azurerm_resource_group.app_grp.name
}

resource "azurerm_network_interface" "app_interface" {
  name                = "app-interface"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "app_vm" {
  name                = "appvm"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = var.location
  size                = "Standard_D2s_v3"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.app_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_mssql_server" "app_server" {
  name                = "myexamplemssqlserver"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = var.location  
  version             = "12.0"
  administrator_login = "sqladmin"
  administrator_login_password = "MyPassword1234"  
}
resource "azurerm_mssql_database" "terradb" {
  name                = "terradb"
  server_id           = azurerm_mssql_server.app_server.id  
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb         = 1
  read_scale          = false

}
