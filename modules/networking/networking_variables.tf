variable "rg_name" {
  description = "Name of the resource group to be imported."
}
variable "tags" {
  description = "The tags to associate with your resource(s)"
  type        = map(string)
}
variable "vnet_name" {
  description = "Name of the VNET"
}
variable "vnet_address_space" {
  description = "Address space for VNET"
}

variable "subnets" { # Plural - it's a collection
  description = "Map of subnets to create under the VNet"
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Enabled") # New API
    private_link_service_network_policies_enabled = optional(bool, true)
    delegation = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    })), [])
  }))
}