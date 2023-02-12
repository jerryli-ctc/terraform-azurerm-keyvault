variable "brand" {
  description = "Default brand name"
  type        = string
  default     = "ezcorp"
}

variable "tenant_id" {
  description = "Tenant id"
  type        = string
  default     = "a63b5a0c-eb96-475e-a563-3ad69174bd79"
}

variable "subnet_name" {
  description = "Specifies the name of the Subnet for Private Endpoint"
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "Specifies the name of the Virtual Network this Subnet is located within for Private Endpoint"
  type        = string
  default     = null
}

variable "vnet_rg" {
  description = "Specifies the name of the resource group the Virtual Network is located in for Private Endpoint"
  type        = string
  default     = null
}

variable "environment" {
  description = "Which enviroment, nonprod or prod for gen1 deployments."
  type        = string
}

variable "object_id" {
  description = "The object ID of a AAD security group in the Azure Active Directory tenant for the vault."
  type        = string
  default     = null
}

variable "role_assignment_parameters" {
  description = <<EOVS
  (Optional) Map with role assignment parameters
  `condition` - (Optional) The condition that limits the resources that the role can be assigned to. Changing this forces a new resource to be created.
  `condition_version` - (Optional) The version of the condition. Possible values are 1.0 or 2.0. Changing this forces a new resource to be created.
  `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
  `description` - (Optional) The description for this Role Assignment. Changing this forces a new resource to be created.
  `skip_service_principal_aad_check` - (Optional) If the principal_id is a newly provisioned Service Principal set this value to true to skip the Azure Active Directory check which may fail due to replication lag. 
  This argument is only valid if the principal_id is a Service Principal identity."
  EOVS
  type        = map(any)
  default     = {}
}

variable "project_name" {
  description = "Project name"
  type        = string
  validation {
    condition = (
      length(var.project_name) <= 12
    )
    error_message = "Project Name shouldn't be longer then 12 Characters."
  }
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "Canada Central"
}

variable "location_code" {
  description = "Your location code (cc or cc)"
  type        = string
  default     = "cc"
  validation {
    condition = (
      var.location_code == "cc" || var.location_code == "ce"
    )
    error_message = "Only regions cc or ce are currently supported."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "enabled_for_deployment" {
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  type        = string
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  type        = string
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  type        = string
  default     = false
}

variable "purge_protection_enabled" {
  description = "Is Purge Protection enabled for this Key Vault? Defaults to false."
  type        = string
  default     = true
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 90
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault."
  type        = string
  default     = "standard"
  validation {
    condition = (
      var.sku_name == "standard" || var.sku_name == "premium"
    )
    error_message = "Possible values are standard and premium."
  }
}

variable "bypass" {
  description = "Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  type        = string
  default     = "None"
  validation {
    condition = (
      var.bypass == "None" || var.bypass == "AzureServices"
    )
    error_message = "Possible values are AzureServices and None."
  }
}

variable "default_action" {
  description = "The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids."
  type        = string
  default     = "Deny"
  validation {
    condition = (
      var.default_action == "Allow" || var.default_action == "Deny"
    )
    error_message = "Possible values are Allow and Deny."
  }
}

variable "ip_rules" {
  description = "One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault."
  type        = list(any)
  default     = []
}

variable "virtual_network_subnet_ids" {
  description = "One or more Subnet ID's which should be able to access this Key Vault."
  type        = list(any)
  default     = []
}

variable "contact" {
  description = <<EOVS
(Optional) One or more contact block as defined below.
email - (Required) E-mail address of the contact.
name - (Optional) Name of the contact.
phone - (Optional) Phone number of the contact.
EOVS
  type        = map(any)
  default     = {}
}

variable "disable_private_endpoint" {
  description = "Disable private endpoint integration for specific use cases."
  type        = string
  default     = false
}

variable "name_override" {
  description = "Setting this will override the default keyvault naming convention but will still append -kv to the end of the name"
  type        = string
  default     = null
}

variable "custom_policy" {
  type = list(object({
    policy_name             = string
    object_id               = string
    certificate_permissions = list(string)
    key_permissions         = list(string)
    secret_permissions      = list(string)
    storage_permissions     = list(string)
  }))
  description = "A list containing a map of custom policy rules, all permissions need to be defined even if not being used"
  default     = []
}

variable "import_certificates" {
  description = <<EOVS
This block supports the following list(map(string)) to generate certificates
`certificate_name` - (Required) Specifies the name of the Key Vault Certificate.
`contents` - (Required) The base64-encoded certificate contents
`password` - (Optional) The password associated with the certificate
`issuer_parameters` - (Required) The name of the Certificate Issuer. Possible values include Self (for self-signed certificate), or Unknown
`exportable` - (Required) Is this Certificate Exportable?
`key_size` - (Required) The size of the Key used in the Certificate. Possible values include 2048, 3072, and 4096
`key_type` - (Required) Specifies the Type of Key, such as RSA
`reuse_key` -  (Required) Is the key reusable? 
`content_type` - (Required) The Content-Type of the Certificate, such as application/x-pkcs12 for a PFX or application/x-pem-file for a PEM
EOVS
  default     = []
  type        = list(any)
}

variable "generate_certificates" {
  description = <<EOVS
This block supports the following list(map(string)) to generate certificates
`certificate_name` - (Required) Specifies the name of the Key Vault Certificate.
`issuer_parameters` - (Required) The name of the Certificate Issuer. Possible values include Self (for self-signed certificate), or Unknown
`exportable` - (Required) Is this Certificate Exportable?
`key_size` - (Required) The size of the Key used in the Certificate. Possible values include 2048, 3072, and 4096
`key_type` - (Required) Specifies the Type of Key, such as RSA
`reuse_key` - (Required) Is the key reusable?
`action_type` - (Required) The Type of action to be performed when the lifetime trigger is triggerec. Possible values include AutoRenew and EmailContacts
`days_before_expiry` - (Optional) The number of days before the Certificate expires that the action associated with this Trigger should run. Conflicts with lifetime_percentage
`lifetime_percentage` - (Optional) The percentage at which during the Certificates Lifetime the action associated with this Trigger should run. Conflicts with days_before_expiry
`content_type` - (Required) The Content-Type of the Certificate, such as application/x-pkcs12 for a PFX or application/x-pem-file for a PEM
`extended_key_usage` - (Optional) A list of Extended/Enhanced Key Usages. 
`key_usage` - (Required) A list of uses associated with this Key. Possible values include cRLSign, dataEncipherment, decipherOnly, digitalSignature, encipherOnly, keyAgreement, keyCertSign, keyEncipherment and nonRepudiation and are case-sensitive
`subject` - (Required) The Certificate's Subject
`validity_in_months` - (Required) The Certificates Validity Period in Months
`dns_names` - (Optional) A list of alternative DNS names (FQDNs) identified by the Certificate
`emails` - (Optional) A list of email addresses identified by this Certificate. 
`upns` - (Optional) A list of User Principal Names identified by the Certificate
EOVS
  default     = []
  type        = list(any)
}

variable "certificate_issuer" {
  description = <<EOVS
This block will manages a Key Vault Certificate Issuer.
`key_vault_id` - (Required) The ID of the Key Vault in which to create the Certificate Issuer.
`name` - (Required) The name which should be used for this Key Vault Certificate Issuer. Changing this forces a new Key Vault Certificate Issuer to be created.
`provider_name` - (Required) The name of the third-party Certificate Issuer. Possible values are: DigiCert, GlobalSign, OneCertV2-PrivateCA, OneCertV2-PublicCA and SslAdminV2.
`org_id` - (Optional) The ID of the organization as provided to the issuer.
`account_id` - (Optional) The account number with the third-party Certificate Issuer.
`admin` - (Optional) One or more admin blocks as defined below.
`password` - (Optional) The password associated with the account and organization ID at the third-party Certificate Issuer. If not specified, will not overwrite any previous value.
EOVS
  default     = []
  type        = list(any)
}

variable "certificate_issuer_admin" {
  default     = {}
  type        = map(any)
  description = <<EOVS
This block will create list of admin blocks.
```
`email_address` - E-mail address of the admin.
`first_name` - First name of the admin.
`last_name` - Last name of the admin.
`phone` - Phone number of the admin.
```
EOVS
}

variable "instance_number" {
  default     = "01"
  description = "instance number of azure keyvault"
}

variable "enable_rbac_authorization" {
  default     = true
  type        = bool
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
}

variable "access_mixed_mode" {
  default     = false
  type        = bool
  description = "Boolean flag to use both Role Based Access Control (RBAC) and Vault Access Policy for authorization of data actions."
}

variable "secrets" {
  description = <<EOVS
This block will create the Key Vault Secrets.
`secret_name` - (Required) The of the secret to be created.
`secret_vaule` - (Required) The value of the coresponding secret to be created.
`secret_content_type` - (Required) The content type for example string or bool.
EOVS
  default     = []
  type        = list(any)
}

variable "keys" {
  description = <<EOVS
This block will create the Key Vault Keys.
`key_name` - (Required) The of the secret to be created.
`key_type' - (Required) Specifies the Key Type to use for this Key Vault Key. Possible values are EC (Elliptic Curve), EC-HSM, Oct (Octet), RSA and RSA-HSM. Changing this forces a new resource to be created.
`key_size` - (Optional) Specifies the Size of the RSA key to create in bytes. For example, 1024 or 2048. Note: This field is required if key_type is RSA or RSA-HSM. Changing this forces a new resource to be created.
`key_opts` - (Required) (Required) A list of JSON web key operations. Possible values include: decrypt, encrypt, sign, unwrapKey, verify and wrapKey. Please note these values are case sensitive.

EOVS
  default     = []
  type        = any
}
variable "log_retention_days" {
  type        = any
  description = "(Required) Log Analytics Workspace log retention days."
  default     = 7
}

variable "metric_log_retention_days" {
  default     = 365
  description = "To store metric logs"
}

variable "diagnostics" {
  description = "Diagnostic settings for those resources that support it. See README.md for details on configuration."
  type = object({
    destination   = string
    eventhub_name = string
    logs          = list(string)
    metrics       = list(string)
  })
  default = null
}

variable "enable_audit_diagnostics" {
  description = "Enable audit diagnostic settings"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources created."
  type        = map(string)
  default     = {}
}

variable "projectcode" {
  description = "Assigned project code"
  type        = string
  default     = null
}

variable "costcenter" {
  description = "Assigned cost center"
  type        = string
  default     = null
}

variable "generation" {
  description = "Type of the infrastructure generation (Gen 1 or Gen 2)."
  type        = string
  default     = "gen2"
  validation {
    condition = (
      var.generation == "gen1" || var.generation == "gen2"
    )
    error_message = "Supported values: gen1 or gen2."
  }
}

variable "log_analytics_workspace_id" {
  description = "Id for log_analytics_workspace. Used to specify the destination for 'audit' logs. If not provided, a default log analytics workspace is choosen as the destination."
  type        = string
  default     = null
}
