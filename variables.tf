## Cato provider variables
variable "baseurl" {
  description = "Cato API base URL"
  type        = string
  default     = "https://api.catonetworks.com/api/v1/graphql2"
}

variable "token" {
  description = "Cato API token"
  type        = string
}

variable "account_id" {
  description = "Cato account ID"
  type        = number
}

# Azure Variables
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "az_location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
}

variable "gateway_subnet_id" {
  description = "The id of the gateway subnet"
  type        = string
}

variable "vpn_gateway_name" {
  description = "The name of the VPN gateway"
  type        = string
}

variable "local_network_gateway_name" {
  description = "The name of the local network gateway"
  type        = string
}

variable "primary_cato_pop_ip" {
  description = "The IP address of the primary Cato POP"
  type        = string
}

variable "secondary_cato_pop_ip" {
  description = "The IP address of the secondary Cato POP"
  type        = string
}

# Cato Variables
variable "site_name" {
  description = "Name of the IPSec site"
  type        = string
}

variable "site_description" {
  description = "Description of the IPSec site"
  type        = string
}

variable "native_network_range" {
  description = "Native network range for the IPSec site"
  type        = string
}

variable "site_type" {
  description = "The type of the site"
  type        = string
  default     = "CLOUD_DC"
  validation {
    condition     = contains(["DATACENTER", "BRANCH", "CLOUD_DC", "HEADQUARTERS"], var.site_type)
    error_message = "The site_type variable must be one of 'DATACENTER','BRANCH','CLOUD_DC','HEADQUARTERS'."
  }
}

variable "site_location" {
  type = object({
    city         = string
    country_code = string
    state_code   = string
    timezone     = string
  })
}

variable "primary_private_cato_ip" {
  description = "Private IP address of the Cato side for the primary tunnel"
  type        = string
}

variable "primary_private_site_ip" {
  description = "Private IP address of the site side for the primary tunnel"
  type        = string
}

variable "primary_public_cato_ip_id" {
  description = "Public IP address ID of the Cato side for the primary tunnel"
  type        = string
}

variable "primary_destination_type" {
  description = "The destination type of the IPsec tunnel"
  # validation {
  #   condition     = var.primary_destination_type == null || contains(["FQDN","IPv4"], var.primary_destination_type)
  #   error_message = "The site_type variable must be one of 'FQDN','IPv4'."
  # }
  # nullable    = true
  type    = string
  default = null
}

variable "primary_pop_location_id" {
  description = "Primary tunnel POP location ID"
  type        = string
  default     = null
}

variable "secondary_private_cato_ip" {
  description = "Private IP address of the Cato side for the secondary tunnel"
  type        = string
}

variable "secondary_private_site_ip" {
  description = "Private IP address of the site side for the secondary tunnel"
  type        = string
}

variable "secondary_public_cato_ip_id" {
  description = "Public IP address ID of the Cato side for the secondary tunnel"
  type        = string
}

variable "secondary_destination_type" {
  description = "The destination type of the IPsec tunnel"
  # validation {
  #   condition     = var.secondary_destination_type == null || contains(["FQDN","IPv4"], var.secondary_destination_type)
  #   error_message = "The destination_type variable must be one of 'FQDN','IPv4'."
  # }
  # nullable    = true
  type    = string
  default = null
}

variable "secondary_pop_location_id" {
  description = "Secondary tunnel POP location ID"
  type        = string
  default     = null
}

variable "downstream_bw" {
  description = "Downstream bandwidth in Mbps"
  type        = number
}

variable "upstream_bw" {
  description = "Upstream bandwidth in Mbps"
  type        = number
}

variable "primary_connection_shared_key" {
  description = "Primary connection shared key"
  type        = string
  default     = null
}

variable "secondary_connection_shared_key" {
  description = "Secondary connection shared key"
  type        = string
  default     = null
}

variable "license_id" {
  description = "The license ID for the Cato vSocket of license type CATO_SITE, CATO_SSE_SITE, CATO_PB, CATO_PB_SSE.  Example License ID value: 'abcde123-abcd-1234-abcd-abcde1234567'.  Note that licenses are for commercial accounts, and not supported for trial accounts."
  type        = string
  default     = null
}

variable "license_bw" {
  description = "The license bandwidth number for the cato site, specifying bandwidth ONLY applies for pooled licenses.  For a standard site license that is not pooled, leave this value null. Must be a number greater than 0 and an increment of 10."
  type        = string
  default     = null
}