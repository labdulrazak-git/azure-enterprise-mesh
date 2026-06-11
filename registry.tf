# Create a secure, private Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "la2026mesh" # <-- Updated
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "The URL endpoint for your private container registry."
}
