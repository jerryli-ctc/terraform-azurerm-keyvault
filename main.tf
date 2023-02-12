locals {
  log_analytics_workspace_id = coalesce(var.log_analytics_workspace_id, "/subscriptions/efe379ac-bba6-4a98-87af-56c784355dc5/resourceGroups/defaultresourcegroup-cca/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-efe379ac-bba6-4a98-87af-56c784355dc5-CCA")
  diag_resource_list         = var.diagnostics != null ? split("/", var.diagnostics.destination) : []
  parsed_diag = var.diagnostics != null ? {
    log_analytics_id   = contains(local.diag_resource_list, "Microsoft.OperationalInsights") ? var.diagnostics.destination : null
    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
    metric             = var.diagnostics.metrics
    log                = var.diagnostics.logs
    } : {
    log_analytics_id   = null
    storage_account_id = null
    event_hub_auth_id  = null
    metric             = []
    log                = []
  }

  module_version = trimspace(file("${path.module}/VERSION"))
  default_tags = {
    costcenter     = var.costcenter
    projectcode    = var.projectcode
    brand          = var.brand
    environment    = var.environment
    location       = var.location
    resource_group = var.resource_group_name
    deployed_using = "Terraform - terraform.azurerm.keyvault ${local.module_version}"
  }

}

resource "azurerm_key_vault" "main" {
  name                            = var.name_override == null ? lower(format("%s%s%s%02d%s-kv", var.brand, var.environment, var.project_name, var.instance_number, var.location_code)) : lower(format("%s-kv", var.name_override))
  location                        = var.location
  resource_group_name             = var.resource_group_name
  sku_name                        = var.sku_name
  tenant_id                       = var.tenant_id
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.soft_delete_retention_days
  tags                            = merge(local.default_tags, var.tags)

  network_acls {
    bypass                     = var.bypass
    default_action             = var.default_action
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.virtual_network_subnet_ids
  }

  dynamic "contact" {
    for_each = var.contact
    content {
      email = contact.value.email
      name  = lookup(contact.value, "name", null)
      phone = lookup(contact.value, "phone", null)
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_key_vault_access_policy" "terraform_default_policies" {
  for_each                = var.enable_rbac_authorization ? [] : toset(["0"])
  key_vault_id            = azurerm_key_vault.main.id
  tenant_id               = var.tenant_id
  object_id               = var.object_id == null ? lookup(local.key_vault_terraform_default_object_id, var.environment) : var.object_id
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"]
  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Purge", "Decrypt", "Encrypt", "Sign", "UnwrapKey", "WrapKey", "Verify"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
  storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
}

resource "azurerm_role_assignment" "rbac_keyvault_admin" {
  for_each                               = var.enable_rbac_authorization ? var.generation == "gen2" && var.object_id == null ? [] : toset(["0"]) : []
  scope                                  = azurerm_key_vault.main.id
  role_definition_name                   = "Key Vault Administrator"
  principal_id                           = var.generation == "gen2" || var.object_id != null ? var.object_id : lookup(local.key_vault_terraform_default_object_id, var.environment)
  condition                              = lookup(var.role_assignment_parameters, "condition", null)
  condition_version                      = lookup(var.role_assignment_parameters, "condition_version", null)
  delegated_managed_identity_resource_id = lookup(var.role_assignment_parameters, "delegated_managed_identity_resource_id", null)
  description                            = lookup(var.role_assignment_parameters, "description", null)
  skip_service_principal_aad_check       = lookup(var.role_assignment_parameters, "skip_service_principal_aad_check", null)
}

resource "azurerm_key_vault_access_policy" "custom_policies" {
  for_each                = { for x in var.custom_policy : x.policy_name => x if var.enable_rbac_authorization == false || var.access_mixed_mode == true }
  key_vault_id            = azurerm_key_vault.main.id
  tenant_id               = var.tenant_id
  object_id               = each.value.object_id
  application_id          = lookup(each.value, "application_id", null)
  certificate_permissions = lookup(each.value, "certificate_permissions", null)
  key_permissions         = lookup(each.value, "key_permissions", null)
  secret_permissions      = lookup(each.value, "secret_permissions", null)
  storage_permissions     = lookup(each.value, "storage_permissions", null)
}

resource "azurerm_key_vault_certificate" "importing" {
  for_each     = { for x in var.import_certificates : x.certificate_name => x }
  name         = lower(format("%s-cert", each.value.certificate_name))
  key_vault_id = azurerm_key_vault.main.id
  tags         = merge(local.default_tags, var.tags)
  lifecycle {
    ignore_changes = [tags]
  }
  certificate {
    contents = each.value.contents
    password = lookup(each.value, "password", null)
  }

  certificate_policy {
    issuer_parameters {
      name = lookup(each.value, "issuer_parameters", "Self")
    }

    key_properties {
      exportable = each.value.exportable
      key_size   = each.value.key_size
      key_type   = each.value.key_type
      reuse_key  = each.value.reuse_key
    }

    secret_properties {
      content_type = each.value.content_type
    }
  }
  depends_on = [azurerm_key_vault_access_policy.terraform_default_policies, azurerm_key_vault_access_policy.custom_policies, azurerm_key_vault.main]
}


resource "azurerm_key_vault_certificate" "generating" {
  for_each     = { for x in var.generate_certificates : x.certificate_name => x }
  name         = lower(format("%s-cert", each.value.certificate_name))
  key_vault_id = azurerm_key_vault.main.id
  tags         = merge(local.default_tags, var.tags)
  lifecycle {
    ignore_changes = [tags]
  }

  certificate_policy {
    issuer_parameters {
      name = lookup(each.value, "issuer_parameters", "Self")
    }

    key_properties {
      exportable = each.value.exportable
      key_size   = each.value.key_size
      key_type   = each.value.key_type
      reuse_key  = each.value.reuse_key
    }

    lifetime_action {
      action {
        action_type = each.value.action_type
      }

      trigger {
        days_before_expiry  = try(each.value.lifetime_percentage, null) == null ? each.value.days_before_expiry : null
        lifetime_percentage = try(each.value.days_before_expiry, null) == null ? each.value.days_before_expiry : null
      }
    }

    secret_properties {
      content_type = each.value.content_type
    }

    # If we generating a new key vault certificate, x509_certificate_properties is required. 
    # But this resource also supports importing a certificate, in this way, this field is optional.
    x509_certificate_properties {
      extended_key_usage = lookup(each.value, "extended_key_usage", null)
      key_usage          = each.value.key_usage
      subject            = each.value.subject
      validity_in_months = each.value.validity_in_months

      subject_alternative_names {
        dns_names = lookup(each.value, "dns_names", null)
        emails    = lookup(each.value, "emails", null)
        upns      = lookup(each.value, "upns", null)
      }
    }
  }

  depends_on = [
    azurerm_key_vault_access_policy.terraform_default_policies,
    azurerm_key_vault_access_policy.custom_policies,
    azurerm_key_vault.main
  ]
}


resource "azurerm_key_vault_certificate_issuer" "main" {
  for_each      = { for x in var.certificate_issuer : x.certificate_issuer => x }
  name          = lower(format("%s-cert-issuer", each.value.certificate_issuer))
  key_vault_id  = azurerm_key_vault.main.id
  provider_name = each.value.provider_name
  org_id        = lookup(each.value, "org_id", null)
  account_id    = lookup(each.value, "account_id", null)
  password      = lookup(each.value, "password", null)
  dynamic "admin" {
    for_each = var.certificate_issuer_admin
    content {
      email_address = lookup(certificate_issuer_admin.value, "email_address ", null)
      first_name    = lookup(certificate_issuer_admin.value, "first_name", null)
      last_name     = lookup(certificate_issuer_admin.value, "last_name", null)
      phone         = lookup(certificate_issuer_admin.value, "phone", null)
    }
  }
  depends_on = [
    azurerm_key_vault_access_policy.terraform_default_policies,
    azurerm_key_vault_access_policy.custom_policies,
    azurerm_key_vault.main
  ]
}

resource "azurerm_key_vault_secret" "main" {
  for_each        = { for x in var.secrets : x.secret_name => x }
  name            = lookup(each.value, "secret_name", null)
  value           = lookup(each.value, "secret_value", null)
  key_vault_id    = azurerm_key_vault.main.id
  content_type    = lookup(each.value, "secret_content_type", null)
  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)
  tags            = merge(local.default_tags, var.tags)
  lifecycle {
    ignore_changes = [tags]
  }
  depends_on = [
    azurerm_key_vault_access_policy.terraform_default_policies,
    azurerm_key_vault_access_policy.custom_policies,
    azurerm_key_vault.main
  ]
}

resource "azurerm_key_vault_key" "main" {
  for_each        = { for x in var.keys : x.key_name => x }
  name            = lookup(each.value, "key_name", null)
  key_vault_id    = azurerm_key_vault.main.id
  key_type        = lookup(each.value, "key_type", null)
  key_size        = lookup(each.value, "key_size", null)
  key_opts        = lookup(each.value, "key_opts", [])
  not_before_date = lookup(each.value, "not_before_date", null)
  expiration_date = lookup(each.value, "expiration_date", null)
  tags            = merge(local.default_tags, var.tags)
  lifecycle {
    ignore_changes = [tags]
  }
  depends_on = [
    azurerm_key_vault_access_policy.terraform_default_policies,
    azurerm_key_vault_access_policy.custom_policies,
    azurerm_key_vault.main
  ]
}

