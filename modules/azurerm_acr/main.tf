resource "azurerm_container_registry" "acr" {

  name                = var.name # alpha numeric characters only are allowed
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  public_network_access_enabled = var.public_access_enabled

  dynamic "georeplications" {
    for_each = (var.sku == "Premium" && var.geo_replica_locs != null) ? toset(
    var.geo_replica_locs) : []
    content {
      location = georeplications.key
      tags     = var.tags
    }
  }
  tags = var.tags
}

resource "azurerm_network_security_rule" "acr" {
  name                        = "SAS-ACR"
  description                 = "Allow ACR from source"
  count                       = (length(var.public_access_cidrs) != 0) ? 1 : 0
  priority                    = 180
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5000"
  source_address_prefixes     = var.public_access_cidrs
  destination_address_prefix  = "*"
  resource_group_name         = var.network_resource_group_name
  network_security_group_name = var.nsg_name
}

resource "azurerm_private_dns_zone" "acr" {
  count = var.public_access_enabled ? 0 : 1

  name                = "privatelink.azurecr.io"
  resource_group_name = var.network_resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  count = var.public_access_enabled ? 0 : 1

  name                  = join("", regexall("[a-zA-Z0-9]+", "${var.prefix}acr"))
  private_dns_zone_name = azurerm_private_dns_zone.acr[0].name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.network_resource_group_name
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "acr" {
  count = var.public_access_enabled ? 0 : 1

  name                = format("%s%s", azurerm_container_registry.acr.name, "-private-endpoint")
  resource_group_name = var.network_resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  tags                = var.tags
  
  private_service_connection {
    name                           = format("%s%s", azurerm_container_registry.acr.name, "-service-connection")
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names = [
      "registry"
    ]
  }
  
  private_dns_zone_group {
    name = format("%s%s", azurerm_container_registry.acr.name, "-private-dns-zone-group")
    
    private_dns_zone_ids = [
      azurerm_private_dns_zone.acr[0].id
    ]  
  }
 
  depends_on = [
    azurerm_container_registry.acr
  ]
}

data "azuread_application" "aks_node_pool" {
  display_name = "${var.prefix}-aks-agentpool"
}

resource "azurerm_role_assignment" "controlplane_akspull" {
  principal_id                     = var.aks_principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "nodepool_akspull" {
  principal_id                     = data.azuread_application.aks_node_pool.object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}