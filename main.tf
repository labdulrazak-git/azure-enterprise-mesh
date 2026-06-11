# 1. Create the Enterprise Hub Resource Group
resource "azurerm_resource_group" "hub" {
  name     = var.hub_prefix
  location = var.location
}

# 2. Create the Hub Virtual Network
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "vnet-prod-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = ["10.0.0.0/16"]
}

# 3. Create the Dedicated Azure Bastion Subnet
# Note: Azure requires this exact name for Bastion to bind to it
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Create the Enterprise Spoke Resource Group
resource "azurerm_resource_group" "spoke" {
  name     = var.spoke_prefix
  location = var.location
}

# 5. Create the Spoke Virtual Network
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "vnet-prod-spoke"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = ["10.1.0.0/16"]
}

# 6. Create the Container Apps Infrastructure Subnet
resource "azurerm_subnet" "aca_subnet" {
  name                 = "snet-prod-aca"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.1.0.0/23"]

  # Explicitly grant Azure Container Apps permission to manage this subnet
  delegation {
    name = "aca-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# 7. Bi-directional Peering: Hub to Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-hub-to-spoke"
  resource_group_name          = azurerm_resource_group.hub.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# 8. Bi-directional Peering: Spoke to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-spoke-to-hub"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
