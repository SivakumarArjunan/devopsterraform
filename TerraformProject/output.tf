output "resource_group_id" {
  description = "The ID of the created Azure resource group"
  value       = azurerm_resource_group.app_grp.id
}

output "storage_account_id" {
  description = "The ID of the created Azure storage account"
  value       = azurerm_storage_account.storage_account.id
}

output "virtual_network_id" {
  description = "The ID of the created Azure virtual network"
  value       = azurerm_virtual_network.app_network.id
}

output "subnet_id" {
  description = "The ID of the created Azure subnet"
  value       = data.azurerm_subnet.SubnetA.id
}

output "network_interface_id" {
  description = "The ID of the created Azure network interface"
  value       = azurerm_network_interface.app_interface.id
}

output "virtual_machine_id" {
  description = "The ID of the created Azure virtual machine"
  value       = azurerm_windows_virtual_machine.app_vm.id
}
output "sql_server_name" {
  description = "SQL Server Name"
  value       = azurerm_mssql_server.app_server.name
}

output "sql_database_name" {
  description = "SQL Database Name"
  value       = azurerm_mssql_database.terradb.name
}
