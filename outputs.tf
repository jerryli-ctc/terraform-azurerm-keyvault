output "vault_id" {
  value       = azurerm_key_vault.main.id
  description = "The ID of the Key Vault."
}

output "vault_uri" {
  value       = azurerm_key_vault.main.vault_uri
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
}

output "vault_name" {
  value       = azurerm_key_vault.main.name
  description = "The Name of the Key Vault."
}

output "vault_certificate_import_id" {
  value       = { for k, v in azurerm_key_vault_certificate.importing : k => v.id }
  description = "The Key Vault Certificate ID."
}

output "vault_certificate_generate_id" {
  value       = { for k, v in azurerm_key_vault_certificate.generating : k => v.id }
  description = "The Key Vault Certificate ID."
}

output "vault_certificate_import_secret_id" {
  value       = { for k, v in azurerm_key_vault_certificate.importing : k => v.secret_id }
  description = "The ID of the associated Key Vault Secret."
}

output "vault_certificate_generate_secret_id" {
  value       = { for k, v in azurerm_key_vault_certificate.generating : k => v.secret_id }
  description = "The ID of the associated Key Vault Secret"
}

output "vault_certificate_generate_versionless_secret" {
  value       = { for k, v in azurerm_key_vault_certificate.generating : k => v.versionless_secret_id }
  description = "The current version of the Key Vault Certificate."
}

output "vault_certificate_import_versionless_secret" {
  value       = { for k, v in azurerm_key_vault_certificate.importing : k => v.versionless_secret_id }
  description = "The current version of the Key Vault Certificate."
}

output "vault_certificate_import_version" {
  value       = { for k, v in azurerm_key_vault_certificate.importing : k => v.version }
  description = "The current version of the Key Vault Certificate."
}

output "vault_certificate_generate_version" {
  value       = { for k, v in azurerm_key_vault_certificate.generating : k => v.version }
  description = "The current version of the Key Vault Certificate."
}

output "vault_certificate_import_certificate_data" {
  value       = { for k, v in azurerm_key_vault_certificate.importing : k => v.certificate_data }
  description = "The raw Key Vault Certificate data represented as a hexadecimal string."
}

output "vault_certificate_generate_certificate_data" {
  value       = { for k, v in azurerm_key_vault_certificate.generating : k => v.certificate_data }
  description = "The raw Key Vault Certificate data represented as a hexadecimal string."
}

output "vault_certificate_import_thumbprint" {
  value       = { for k, v in azurerm_key_vault_certificate.importing : k => v.thumbprint }
  description = "The raw Key Vault Certificate data represented as a hexadecimal string."
}

output "vault_certificate_generate_thumbprint" {
  value       = { for k, v in azurerm_key_vault_certificate.generating : k => v.thumbprint }
  description = "The raw Key Vault Certificate data represented as a hexadecimal string."
}

output "vault_key_vault_certificate_issuer" {
  value       = { for k, v in azurerm_key_vault_certificate_issuer.main : k => v.id }
  description = "The ID of the Key Vault Certificate Issuer."
}

output "vault_secret_id" {
  value       = { for k, v in azurerm_key_vault_secret.main : k => v.id }
  description = "The ID of the created Key Vault Secret"
}

output "vault_secret_version" {
  value       = { for k, v in azurerm_key_vault_secret.main : k => v.version }
  description = "The current version of the Key Vault Secret."
}


output "vault_secret_value" {
  value       = { for k, v in azurerm_key_vault_secret.main : k => v.value }
  description = "The current value of the Key Vault Secret."
  sensitive   = true
}

// key
output "vault_key_id" {
  value       = { for k, v in azurerm_key_vault_key.main : k => v.id }
  description = "The Key Vault Key ID"
}

output "vault_key_version" {
  value       = { for k, v in azurerm_key_vault_key.main : k => v.version }
  description = "The current version of the Key Vault Key."
}

output "vault_key_public_key_pem" {
  value       = { for k, v in azurerm_key_vault_key.main : k => v.public_key_pem }
  description = "The PEM encoded public key of this Key Vault Key."
  sensitive   = true
}

output "vault_key_public_key_openssh" {
  value       = { for k, v in azurerm_key_vault_key.main : k => v.public_key_openssh }
  description = "The OpenSSH encoded public key of this Key Vault."
  sensitive   = true
}
