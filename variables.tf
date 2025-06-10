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
variable "azure_resource_group_name" {
  description = "The name of the Azure resource group to build / use"
  type        = string
}

variable "az_location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "azure_enable_activeactive" {
  description = "Whether to Enable Active/Active - Default & Recommendation is true (Enabled)"
  type        = bool
  default     = true
}

variable "azure_vnet_name" {
  description = "The name of the Virtual Network to Build / Use"
  type        = string
  default     = null
}

variable "build_azure_resource_group" {
  description = "Whether or not to build a new resource group for this deployment"
  type        = bool
}

variable "build_azure_vng_vnet" {
  description = "Whether or not to build a new virtual network for this deployment"
  type        = bool
}

variable "azure_local_networks" {
  description = <<EOF
  (Optional) List of Networks on the Azure side (if BGP is disabled)
  Examples: 
  ["servers:10.0.0.0/24","devices:10.1.0.0/24"]
  EOF
  type        = list(string)
  default     = null
}

variable "azure_vng_vnet_range" {
  description = "CIDR range for the Virtual Network, if we're building it."
  type        = string
  default     = null
}

variable "azure_vng_subnet_range" {
  description = "CIDR range for the Subnet in the Virtual Network, if we're building it."
  type        = string
  default     = null
}

variable "azure_gateway_subnet_id" {
  description = "The id of the gateway subnet, if pre-existing"
  type        = string
  default     = null
}


variable "azure_ipsec_version" {
  description = <<EOF
  Version of IPSec to Use, valid responses are 'IKEv1' and 'IKEv2'. 
  Recommended Value is IKEv2 
  Default is IKEv2
  EOF
  type        = string
  default     = "IKEv2"
}

variable "azure_primary_connection_ike_encryption" {
  description = "The IKE encryption algorithm (Phase 1). Default: AES256"
  type        = string
  default     = "AES256"
}

variable "azure_primary_connection_ike_integrity" {
  description = "The IKE integrity algorithm (Phase 1). Default: SHA256"
  type        = string
  default     = "SHA256"
}

variable "azure_primary_connection_dh_group" {
  description = "The Diffie-Hellman Group used in IKE Phase 1. Default: DHGroup14 (Because Azure doesn't support DHGroup15)"
  type        = string
  default     = "DHGroup14"
}

variable "azure_primary_connection_ipsec_encryption" {
  description = "The IPsec encryption algorithm (Phase 2). Default: AES256"
  type        = string
  default     = "AES256"
}

variable "azure_primary_connection_ipsec_integrity" {
  description = "The IPsec integrity algorithm (Phase 2). Default: SHA256"
  type        = string
  default     = "SHA256"
}

variable "azure_primary_connection_pfs_group" {
  description = "The Perfect Forward Secrecy (PFS) group used in IPsec Phase 2. Default: PFS14 (Because Azure doesn't support PFS15)"
  type        = string
  default     = "PFS14"
}

variable "azure_primary_connection_sa_lifetime" {
  description = "The Security Association (SA) lifetime in seconds.  Default: 19800"
  type        = number
  default     = 19800
}

variable "azure_secondary_connection_ike_encryption" {
  description = "The IKE encryption algorithm (Phase 1) for the secondary connection. Default: AES256"
  type        = string
  default     = "AES256"
}

variable "azure_secondary_connection_ike_integrity" {
  description = "The IKE integrity algorithm (Phase 1) for the secondary connection. Default: SHA256"
  type        = string
  default     = "SHA256"
}

variable "azure_secondary_connection_dh_group" {
  description = "The Diffie-Hellman Group used in IKE Phase 1 for the secondary connection. Default: DHGroup14 (Because Azure doesn't support DHGroup15)"
  type        = string
  default     = "DHGroup14"
}

variable "azure_secondary_connection_ipsec_encryption" {
  description = "The IPsec encryption algorithm (Phase 2) for the secondary connection. Default: AES256"
  type        = string
  default     = "AES256"
}

variable "azure_secondary_connection_ipsec_integrity" {
  description = "The IPsec integrity algorithm (Phase 2) for the secondary connection. Default: SHA256"
  type        = string
  default     = "SHA256"
}

variable "azure_secondary_connection_pfs_group" {
  description = "The Perfect Forward Secrecy (PFS) group used in IPsec Phase 2 for the secondary connection. Default: PFS14 (Because Azure doesn't support PFS15)"
  type        = string
  default     = "PFS14"
}

variable "azure_secondary_connection_sa_lifetime" {
  description = "The Security Association (SA) lifetime in seconds for the secondary connection. Default: 19800"
  type        = number
  default     = 19800
}

variable "tags" {
  description = <<EOF
  A map of Keys & Values to describe the infrastructure
  Example: 
  { 
  terraform = "true"
  built_by = "Your Name"
  }
  EOF
  type        = map(string)
  default     = {}
}

variable "azure_enable_bgp" {
  description = "Enable BGP within Azure"
  type        = bool
  default     = false
}

# --- BGP Specific Variables (only used if azure_enable_bgp is true) ---

variable "azure_bgp_asn" {
  description = "The BGP Autonomous System Number for the Azure VPN Gateway. Required if azure_enable_bgp is true."
  type        = number
  default     = 65515
}

variable "cato_bgp_asn" {
  description = "The BGP Autonomous System Number for the Cato PoPs. Required if azure_enable_bgp is true."
  type        = number
  default     = 65001
}

variable "cato_primary_bgp_metric" {
  description = "Metric for the primary Cato BGP peer to influence route preference."
  type        = number
  default     = 100
}

variable "cato_secondary_bgp_metric" {
  description = "Metric for the secondary Cato BGP peer to influence route preference."
  type        = number
  default     = 200
}

# --- BGP Specific Variables (only used if azure_enable_bgp is true) ---

variable "cato_primary_bgp_peer_name" {
  description = "Cato Primary BGP Peer Name"
  type        = string
  default     = null
}

variable "cato_secondary_bgp_peer_name" {
  description = "Cato Secondary BGP Peer Name"
  type        = string
  default     = null
}

variable "cato_primary_bgp_default_action" {
  description = "Cato Primary BGP Default Action"
  type        = string
  default     = "ACCEPT"
}

variable "cato_secondary_bgp_default_action" {
  description = "Cato Secondary BGP Default Action"
  type        = string
  default     = "ACCEPT"
}

variable "cato_primary_bgp_advertise_all" {
  description = "Cato Primary BGP Advertise All"
  type        = bool
  default     = true
}

variable "cato_secondary_bgp_advertise_all" {
  description = "Cato Secondary BGP Advertise All"
  type        = bool
  default     = true
}

variable "cato_primary_bgp_advertise_default_route" {
  description = "Cato Primary BGP Advertise Default Route"
  type        = bool
  default     = false
}

variable "cato_secondary_bgp_advertise_default_route" {
  description = "Cato Secondary BGP Advertise Default Route"
  type        = bool
  default     = false
}

variable "cato_primary_bgp_advertise_summary_route" {
  description = "Cato Primary BGP Advertise Summary Route"
  type        = bool
  default     = false
}

variable "cato_secondary_bgp_advertise_summary_route" {
  description = "Cato Secondary BGP Advertise Summary Route"
  type        = bool
  default     = false
}

variable "cato_primary_bgp_bfd_transmit_interval" {
  description = "Cato Primary BGP BFD Transmit Interval"
  type        = number
  default     = 1000
}

variable "cato_secondary_bgp_bfd_transmit_interval" {
  description = "Cato Secondary BGP BFD Transmit Interval"
  type        = number
  default     = 1000
}

variable "cato_primary_bgp_bfd_receive_interval" {
  description = "Cato Primary BGP BFD Receive Interval"
  type        = number
  default     = 1000
}

variable "cato_secondary_bgp_bfd_receive_interval" {
  description = "Cato Secondary BGP BFD Receive Interval"
  type        = number
  default     = 1000
}

variable "cato_primary_bgp_bfd_multiplier" {
  description = "Cato Primary BGP BFD Multiplier"
  type        = number
  default     = 5
}

variable "cato_secondary_bgp_bfd_multiplier" {
  description = "Cato Secondary BGP BFD Multiplier"
  type        = number
  default     = 5
}

# Cato Variables
variable "primary_cato_pop_ip" {
  description = "The IP address of the primary Cato POP"
  type        = string
}

variable "secondary_cato_pop_ip" {
  description = "The IP address of the secondary Cato POP"
  type        = string
}

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
  description = <<EOF
  The BGP peering IP address for the CatoPOP (APIPA). Required if azure_enable_bgp is true.
  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255.
  EOF
  type        = string
  default     = null
}

variable "primary_private_site_ip" {
  description = <<EOF
  The BGP peering IP address for the Azure VPN Gateway (APIPA). Required if azure_enable_bgp is true.
  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255.
  EOF
  type        = string
  default     = null
}


variable "primary_destination_type" {
  description = "The destination type of the IPsec tunnel"
  type        = string
  default     = null
}

variable "primary_pop_location_id" {
  description = "Primary tunnel POP location ID"
  type        = string
  default     = null
}

variable "secondary_private_cato_ip" {
  description = <<EOF
  The BGP peering IP address for the CatoPOP (APIPA). Required if azure_enable_bgp is true.
  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255.
  EOF
  type        = string
  default     = null
}

variable "secondary_private_site_ip" {
  description = <<EOF
  The BGP peering IP address for the Azure VPN Gateway (APIPA). Required if azure_enable_bgp is true.
  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255.
  EOF
  type        = string
  default     = null
}

variable "secondary_destination_type" {
  description = "The destination type of the IPsec tunnel"
  type        = string
  default     = null
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

variable "cato_local_networks" {
  description = <<EOF
  If we aren't using BGP, we will need a list of CIDRs which live behind Cato
  for more information https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range 
  Default: ["10.41.0.0/16", "10.254.254.0/24"] 
  EOF 

  type = list(string)
  default = [
    "10.41.0.0/16",   #Cato VPN Client 
    "10.254.254.0/24" #Cato System Range https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range
  ]
}

variable "cato_initMessage_dhGroup" {
  description = <<EOF
   Cato Phase 1 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is 
   the corresponding prime modulus size in bits
   Valid Options are: 
    AUTOMATIC
    DH_14_MODP2048
    DH_15_MODP3072
    DH_16_MODP4096
    DH_19_ECP256
    DH_2_MODP1024
    DH_20_ECP384
    DH_21_ECP521
    DH_5_MODP1536
    NONE
    Default to DH_14_MODP2048
    EOF
  type        = string
  default     = "DH_14_MODP2048"
}

variable "cato_initMessage_cipher" {
  description = <<EOF
  Cato Phase 1 ciphers.  The SA tunnel encryption method. Note: For situations where GCM isn’t supported for the INIT phase, 
  we recommend that you use the CBC algorithm for the INIT phase, and GCM for AUTH
  Valid options are: 
    AES_CBC_128
    AES_CBC_256
    AES_GCM_128
    AES_GCM_256
    AUTOMATIC
    DES3_CBC
    NONE
    Default to AUTOMATIC
    EOF
  type        = string
  default     = "AUTOMATIC"
}

variable "cato_initMessage_integrity" {
  description = <<EOF
  Cato Phase 1 Hashing Algorithm.  The algorithm used to verify the integrity and authenticity of IPsec packets
   Valid Options are: 
    AUTOMATIC
    MD5
    NONE
    SHA1
    SHA256
    SHA384
    SHA512
    Default to AUTOMATIC
    EOF
  type        = string
  default     = "AUTOMATIC"
}

variable "cato_initMessage_prf" {
  description = <<EOF
  Cato Phase 1 Hashing Algorithm for The Pseudo-random function (PRF) used to derive the cryptographic keys used in the SA establishment process. 
  Valid Options are: 
    AUTOMATIC
    MD5
    NONE
    SHA1
    SHA256
    SHA384
    SHA512
    Default to AUTOMATIC
    EOF
  type        = string
  default     = "AUTOMATIC"
}

variable "cato_authMessage_dhGroup" {
  description = <<EOF
   Cato Phase 2 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is 
   the corresponding prime modulus size in bits
   Valid Options are: 
    AUTOMATIC
    DH_14_MODP2048
    DH_15_MODP3072
    DH_16_MODP4096
    DH_19_ECP256
    DH_2_MODP1024
    DH_20_ECP384
    DH_21_ECP521
    DH_5_MODP1536
    NONE
    Default to DH_14_MODP2048
    EOF
  type        = string
  default     = "DH_14_MODP2048"
}

variable "cato_authMessage_cipher" {
  description = <<EOF
  Cato Phase 2 ciphers.  The SA tunnel encryption method. Note: For situations where GCM isn’t supported for the INIT phase, 
  we recommend that you use the CBC algorithm for the INIT phase, and GCM for AUTH
  Valid options are: 
    AES_CBC_128
    AES_CBC_256
    AES_GCM_128
    AES_GCM_256
    AUTOMATIC
    DES3_CBC
    NONE
    Default to AUTOMATIC
    EOF
  type        = string
  default     = "AUTOMATIC"
}

variable "cato_authMessage_integrity" {
  description = <<EOF
  Cato Phase 2 Hashing Algorithm.  The algorithm used to verify the integrity and authenticity of IPsec packets
    Valid Options are: 
    AUTOMATIC
    MD5
    NONE
    SHA1
    SHA256
    SHA384
    SHA512
    Default to AUTOMATIC
    EOF
  type        = string
  default     = "AUTOMATIC"
}

variable "cato_connectionMode" {
  description = <<EOF
  Cato Connection Mode.  Determines the protocol for establishing the Security Association (SA) Tunnel. 
  Valid values are: Responder-Only Mode: Cato Cloud only responds to incoming requests by the initiator (e.g. a Firewall device) to establish a security association. 
  Bidirectional Mode: Both Cato Cloud and the peer device on customer site can initiate the IPSec SA establishment.  
  Valid Options are: 
    BIDIRECTIONAL
    RESPONDER_ONLY
    Default to BIDIRECTIONAL
    EOF
  type        = string
  default     = "BIDIRECTIONAL"
}

variable "cato_identificationType" {
  description = <<EOF
  Cato Identification Type.  The authentication identification type used for SA authentication. When using “BIDIRECTIONAL”, it is set to “IPv4” by default. 
  Other methods are available in Responder mode only. 
  Valid Options are: 
    EMAIL
    FQDN
    IPV4
    KEY_ID
    Default to IPV4
    EOF
  type        = string
  default     = "IPV4"
}