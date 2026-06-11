# 1. Create a Log Analytics Workspace for Container Logs
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-prod-aca-workspace"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 2. Create the Container Apps Managed Environment inside the Spoke Subnet
resource "azurerm_container_app_environment" "aca_env" {
  name                           = "cae-prod-secure"
  location                       = azurerm_resource_group.spoke.location
  resource_group_name            = azurerm_resource_group.spoke.name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.logs.id
  infrastructure_subnet_id       = azurerm_subnet.aca_subnet.id
  internal_load_balancer_enabled = true # Keeps the environment hidden from the public internet
}
