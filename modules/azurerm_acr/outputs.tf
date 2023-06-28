output "name" {
  description = "The name of the ACR"
  value       = azurerm_container_registry.acr.name
}

output "id" {
  description = "The id of the ACR"
  value       = azurerm_container_registry.acr.id
}

output "login_server" {
  description = "The URL of the ACR"
  value       = azurerm_container_registry.acr.login_server
}

output "admin_username" {
  description = "The name of the ACR admin"
  value       = azurerm_container_registry.acr.admin_username
}

output "admin_password" {
  description = "The password of the ACR admin"
  value       = azurerm_container_registry.acr.admin_password
}