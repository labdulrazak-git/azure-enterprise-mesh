# Deploy the Serverless Container App
resource "azurerm_container_app" "web_app" {
  name                         = "app-prod-secure"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = azurerm_resource_group.spoke.name
  revision_mode                = "Single"

  # Define the registry credentials to pull our private image
  registry {
    server               = azurerm_container_registry.acr.login_server
    username             = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  # Store the ACR password securely as a secret in the app
  secret {
    name  = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  # Configure the container runtime
  template {
    container {
      name   = "cloudapp"
      image  = "${azurerm_container_registry.acr.login_server}/cloudapp:v1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
    # Cost Optimization: Scale to zero when not in use
    min_replicas = 0
    max_replicas = 1
  }

  # Configure Internal Network Ingress
  ingress {
    allow_insecure_connections = false
    external_enabled           = false # Keeps the app completely hidden inside the VNet
    target_port                = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# Output the internal FQDN (Fully Qualified Domain Name) so we can test it
output "app_internal_url" {
  value       = azurerm_container_app.web_app.latest_revision_fqdn
  description = "The internal VNet URL of your secure application."
}
