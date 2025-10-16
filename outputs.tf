output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.sql_rg.name
}

output "virtual_machine_id" {
  description = "ID of the SQL virtual machine"
  value       = azurerm_windows_virtual_machine.sql_vm.id
}

output "virtual_machine_name" {
  description = "Name of the SQL virtual machine"
  value       = azurerm_windows_virtual_machine.sql_vm.name
}

output "public_ip_address" {
  description = "Public IP address of the SQL VM"
  value       = azurerm_public_ip.sql_public_ip.ip_address
}

output "private_ip_address" {
  description = "Private IP address of the SQL VM"
  value       = azurerm_network_interface.sql_nic.private_ip_address
}

output "sql_virtual_machine_id" {
  description = "ID of the SQL IaaS extension registration"
  value       = azurerm_mssql_virtual_machine.sql_iaas.id
}

output "admin_username" {
  description = "Administrator username for the VM"
  value       = var.admin_username
}

output "storage_account_name" {
  description = "Name of the storage account for SQL backups"
  value       = azurerm_storage_account.sql_storage.name
}
