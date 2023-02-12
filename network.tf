locals {
  vnet_rg     = var.disable_private_endpoint ? null : var.vnet_rg == null ? "ez-${var.environment}-corenetwork-${var.location_code}-rg" : var.vnet_rg
  subnet_name = var.disable_private_endpoint ? null : var.subnet_name == null ? "ez-${var.environment}-corenetwork-${var.location_code}-vnet-app01-snet" : var.subnet_name
  vnet_name   = var.disable_private_endpoint ? null : var.vnet_name == null ? "ez-${var.environment}-corenetwork-${var.location_code}-vnet" : var.vnet_name

  subscription_id = replace(regex("subscriptions/[^/]*", azurerm_key_vault.main.id), "subscriptions/", "")
  subnet_id       = var.disable_private_endpoint ? null : format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s", local.subscription_id, local.vnet_rg, local.vnet_name, local.subnet_name)
}

resource "azurerm_private_endpoint" "main" {
  for_each            = var.disable_private_endpoint ? [] : toset(["0"])
  name                = lower(format("kv-%s-pe", azurerm_key_vault.main.name))
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = local.subnet_id

  private_service_connection {
    name                           = lower(format("kv-%s-pc", azurerm_key_vault.main.name))
    is_manual_connection           = "false"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
  }
  depends_on = [azurerm_key_vault.main]

  lifecycle {
    ignore_changes = [tags]
  }
}