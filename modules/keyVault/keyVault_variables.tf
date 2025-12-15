variable "rg_name" {
  description = "Name of the resource group to be imported."
}
variable "tags" {
  description = "The tags to associate with your resource(s)"
  type        = map(string)
}

variable "keyvault_access_policy" {
  description = "Optional access policies for Key Vault"
  type = map(object({
    tenant_id               = string
    object_id               = string
    certificate_permissions = optional(list(string), [])
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
  }))
  default = {}
}

variable "key_vault_name" {
  description = "Name of the key vault"
}

variable "key_vault_sku" {
  description = "SKU of the key vault"
}

variable "tenant_id" {
  description = "Tenant ID"
}