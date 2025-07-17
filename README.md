# CATO IPSec Azure Terraform module

Terraform module which creates an IPsec site in the Cato Management Application (CMA), and a primary and secondary IPsec tunnel from Azure to the Cato platform.

## NOTE
- For help with finding exact sytax to match site location for city, state_name, country_name and timezone, please refer to the [cato_siteLocation data source](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/siteLocation).
- For help with finding a license id to assign, please refer to the [cato_licensingInfo data source](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/licensingInfo).

## Usage

Example module usage:

```hcl
variable "baseurl" {}
variable "token" {}
variable "account_id" {}
variable "azure_subscription_id" {
  default = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

#Example to Build with BGP (Recommended Configuration)
module "ipsec-azure-bgp" {
  source                     = "catonetworks/ipsec-azure/cato"
  token                      = var.token #Cato Token
  account_id                 = var.account_id
  az_location                = "<Region>" #e.g. "Central US" 
  
  # Whether or not the module should build the resource group.
  build_azure_resource_group = true 
  
  # Whether or not the module should build the virtual network. If the vNet Already exists,
  # Provide the name with azure_vnet_name = "<vnet-name>"
  # if the Vnet Exists, we assume that there is already a subnet defined with the name of 
  # GatewaySubnet as required by Azure.
  build_azure_vng_vnet       = true 
  
  azure_resource_group_name  = "Your-RG-Name-Here"
  azure_vng_vnet_range       = "10.0.0.0/24"
  azure_vng_subnet_range     = "10.0.0.0/24"
  site_name                  = "My-Azure-Cato-IPSec-Site-bgp"
  site_description           = "My Azure Cato IPSEC Site with BGP"
  native_network_range       = "10.0.0.0/23"
  
  # BGP Peering Addresses are required to be within the range of 169.254.21.0 
  # through 169.254.22.255, per Azure Requirements.

  # BGP Peering Addresses - Primary 
  primary_private_cato_ip    = "169.254.21.2"
  primary_private_site_ip    = "169.254.21.1"
  
  # BGP Peering Addresses - Secondary
  secondary_private_cato_ip  = "169.254.22.2"
  secondary_private_site_ip  = "169.254.22.1"

  # Allocated IPs used for this connection, obtained via CMA
  # See https://support.catonetworks.com/hc/en-us/articles/4413273467153-Allocating-IP-Addresses-for-the-Account
  primary_cato_pop_ip        = "x.x.x.x" # Your Primary Cato IP
  secondary_cato_pop_ip      = "y.y.y.y" # Your Secondary Cato IP ID

  downstream_bw              = 100
  upstream_bw                = 100
  
  # BGP is enabled via bool (true/false below). 
  # Active/Active VNG is on by Default
  azure_enable_bgp           = true #Requires Active/Active
  
  site_location = {
    city         = "New York City"
    country_code = "US"
    state_code   = "US-NY"
    timezone     = "America/New_York"
  }

  #Example Tags 
  tags = {
    builtwith  = "terraform"
    repo = "https://github.com/catonetworks/terraform-cato-ipsec-azure"
    example_key = "example_value"
  }
}


# Example without BGP.
module "ipsec-azure-nobgp" {
  source                     = "catonetworks/ipsec-azure/cato"
  token                      = var.token
  account_id                 = var.account_id
  az_location                = "<region>" #e.g. "Central US

   # Whether or not the module should build the resource group.
  build_azure_resource_group = true

  # Whether or not the module should build the virtual network. If the vNet Already exists,
  # Provide the name with azure_vnet_name = "<vnet-name>"
  # if the Vnet Exists, we assume that there is already a subnet defined with the name of 
  # GatewaySubnet as required by Azure.
  build_azure_vng_vnet       = true

  azure_resource_group_name  = "Your-RG-Name-Here"
  azure_vng_vnet_range       = "10.0.2.0/24"
  azure_vng_subnet_range     = "10.0.2.0/24"
  site_name                  = "My-Azure-Cato-IPSec-Site-nobgp"
  site_description           = "My Azure Cato IPSEC Site without BGP"
  native_network_range       = "10.0.2.0/23"

  # Allocated IPs used for this connection, obtained via CMA
  # See https://support.catonetworks.com/hc/en-us/articles/4413273467153-Allocating-IP-Addresses-for-the-Account
  primary_cato_pop_ip        = "x.x.x.x" # Your Primary Cato IP
  secondary_cato_pop_ip      = "y.y.y.y" # Your Secondary Cato IP ID

  # Since we're not doing BGP, we have to specify the encryption 
  # Domain that needs to be passed over the tunnel:
  cato_local_networks        = ["10.41.0.0/16", "10.254.254.0/24"]

  # If Left blank, we will accept all networks, vs if Values are here, the SAs must match on both sides. 
  azure_local_networks       = ["service1:10.0.2.0/24", "service2:10.0.3.0/24"]

  downstream_bw    = 100
  upstream_bw      = 100

  # We're not using BGP in this example, so disable.
  azure_enable_bgp = false

  site_location = {
    city         = "New York City"
    country_code = "US"
    state_code   = "US-NY"
    timezone     = "America/New_York"
  }

  #Example Tags 
  tags = {
    builtwith  = "terraform"
    repo = "https://github.com/catonetworks/terraform-cato-ipsec-azure"
    example_key = "example_value"
  }
}

```

## Alloacted IP Reference

You must first [allocate two Cato IPs](https://support.catonetworks.com/hc/en-us/articles/4413273467153-Allocating-IP-Addresses-for-the-Account), and retrieve the IPs, and IDs to be used in the module. Use the [Cato CLI](https://github.com/catonetworks/cato-cli) to retrieve the IPs and IDs for an account.

```bash
$ pip3 install catocli
$ export CATO_TOKEN="your-api-token-here"
$ export CATO_ACCOUNT_ID="your-account-id"
$ catocli entity allocatedIP list
```

## Site Location Reference

For more information on site_location syntax, use the [Cato CLI](https://github.com/catonetworks/cato-cli) to lookup values.

```bash
$ pip3 install catocli
$ export CATO_TOKEN="your-api-token-here"
$ export CATO_ACCOUNT_ID="your-account-id"
$ catocli query siteLocation -h
$ catocli query siteLocation '{"filters":[{"search": "San Diego","field":"city","operation":"exact"}]}' -p
```

## Authors

Module is maintained by [Cato Networks](https://github.com/catonetworks) with help from [these awesome contributors](https://github.com/catonetworks/terraform-cato-ipsec-aws/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/catonetworks/terraform-cato-ipsec-aws/tree/master/LICENSE) for full details.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.1.0 |
| <a name="requirement_cato"></a> [cato](#requirement\_cato) | >= 0.0.30 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.1.0 |
| <a name="provider_cato"></a> [cato](#provider\_cato) | >= 0.0.30 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_local_network_gateway.cato_pop_primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_local_network_gateway.cato_pop_secondary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_public_ip.vpn_gateway_primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.vpn_gateway_secondary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.network_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.vng_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vng_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_gateway.vpn_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_connection.cato_connection_primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [azurerm_virtual_network_gateway_connection.cato_connection_secondary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [cato_bgp_peer.backup](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/bgp_peer) | resource |
| [cato_bgp_peer.primary](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/bgp_peer) | resource |
| [cato_ipsec_site.ipsec-site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/ipsec_site) | resource |
| [cato_license.license](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/license) | resource |
| [random_password.shared_key_primary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.shared_key_secondary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_data.update_ipsec_site_details-bgp](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.update_ipsec_site_details-nobgp](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [cato_allocatedIp.primary](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/allocatedIp) | data source |
| [cato_allocatedIp.secondary](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/allocatedIp) | data source |
| [cato_siteLocation.site_location](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/siteLocation) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cato account ID | `number` | n/a | yes |
| <a name="input_az_location"></a> [az\_location](#input\_az\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_azure_bgp_asn"></a> [azure\_bgp\_asn](#input\_azure\_bgp\_asn) | The BGP Autonomous System Number for the Azure VPN Gateway. Required if azure\_enable\_bgp is true. | `number` | `65515` | no |
| <a name="input_azure_enable_activeactive"></a> [azure\_enable\_activeactive](#input\_azure\_enable\_activeactive) | Whether to Enable Active/Active - Default & Recommendation is true (Enabled) | `bool` | `true` | no |
| <a name="input_azure_enable_bgp"></a> [azure\_enable\_bgp](#input\_azure\_enable\_bgp) | Enable BGP within Azure | `bool` | `false` | no |
| <a name="input_azure_gateway_subnet_id"></a> [azure\_gateway\_subnet\_id](#input\_azure\_gateway\_subnet\_id) | The id of the gateway subnet, if pre-existing | `string` | `null` | no |
| <a name="input_azure_ipsec_version"></a> [azure\_ipsec\_version](#input\_azure\_ipsec\_version) | Version of IPSec to Use, valid responses are 'IKEv1' and 'IKEv2'. <br/>  Recommended Value is IKEv2 <br/>  Default is IKEv2 | `string` | `"IKEv2"` | no |
| <a name="input_azure_local_networks"></a> [azure\_local\_networks](#input\_azure\_local\_networks) | (Optional) List of Networks on the Azure side (if BGP is disabled)<br/>  Examples: <br/>  ["servers:10.0.0.0/24","devices:10.1.0.0/24"] | `list(string)` | `null` | no |
| <a name="input_azure_primary_connection_dh_group"></a> [azure\_primary\_connection\_dh\_group](#input\_azure\_primary\_connection\_dh\_group) | The Diffie-Hellman Group used in IKE Phase 1. Default: DHGroup14 (Because Azure doesn't support DHGroup15) | `string` | `"DHGroup14"` | no |
| <a name="input_azure_primary_connection_ike_encryption"></a> [azure\_primary\_connection\_ike\_encryption](#input\_azure\_primary\_connection\_ike\_encryption) | The IKE encryption algorithm (Phase 1). Default: AES256 | `string` | `"AES256"` | no |
| <a name="input_azure_primary_connection_ike_integrity"></a> [azure\_primary\_connection\_ike\_integrity](#input\_azure\_primary\_connection\_ike\_integrity) | The IKE integrity algorithm (Phase 1). Default: SHA256 | `string` | `"SHA256"` | no |
| <a name="input_azure_primary_connection_ipsec_encryption"></a> [azure\_primary\_connection\_ipsec\_encryption](#input\_azure\_primary\_connection\_ipsec\_encryption) | The IPsec encryption algorithm (Phase 2). Default: AES256 | `string` | `"AES256"` | no |
| <a name="input_azure_primary_connection_ipsec_integrity"></a> [azure\_primary\_connection\_ipsec\_integrity](#input\_azure\_primary\_connection\_ipsec\_integrity) | The IPsec integrity algorithm (Phase 2). Default: SHA256 | `string` | `"SHA256"` | no |
| <a name="input_azure_primary_connection_pfs_group"></a> [azure\_primary\_connection\_pfs\_group](#input\_azure\_primary\_connection\_pfs\_group) | The Perfect Forward Secrecy (PFS) group used in IPsec Phase 2. Default: PFS14 (Because Azure doesn't support PFS15) | `string` | `"PFS14"` | no |
| <a name="input_azure_primary_connection_sa_lifetime"></a> [azure\_primary\_connection\_sa\_lifetime](#input\_azure\_primary\_connection\_sa\_lifetime) | The Security Association (SA) lifetime in seconds.  Default: 19800 | `number` | `19800` | no |
| <a name="input_azure_resource_group_name"></a> [azure\_resource\_group\_name](#input\_azure\_resource\_group\_name) | The name of the Azure resource group to build / use | `string` | n/a | yes |
| <a name="input_azure_secondary_connection_dh_group"></a> [azure\_secondary\_connection\_dh\_group](#input\_azure\_secondary\_connection\_dh\_group) | The Diffie-Hellman Group used in IKE Phase 1 for the secondary connection. Default: DHGroup14 (Because Azure doesn't support DHGroup15) | `string` | `"DHGroup14"` | no |
| <a name="input_azure_secondary_connection_ike_encryption"></a> [azure\_secondary\_connection\_ike\_encryption](#input\_azure\_secondary\_connection\_ike\_encryption) | The IKE encryption algorithm (Phase 1) for the secondary connection. Default: AES256 | `string` | `"AES256"` | no |
| <a name="input_azure_secondary_connection_ike_integrity"></a> [azure\_secondary\_connection\_ike\_integrity](#input\_azure\_secondary\_connection\_ike\_integrity) | The IKE integrity algorithm (Phase 1) for the secondary connection. Default: SHA256 | `string` | `"SHA256"` | no |
| <a name="input_azure_secondary_connection_ipsec_encryption"></a> [azure\_secondary\_connection\_ipsec\_encryption](#input\_azure\_secondary\_connection\_ipsec\_encryption) | The IPsec encryption algorithm (Phase 2) for the secondary connection. Default: AES256 | `string` | `"AES256"` | no |
| <a name="input_azure_secondary_connection_ipsec_integrity"></a> [azure\_secondary\_connection\_ipsec\_integrity](#input\_azure\_secondary\_connection\_ipsec\_integrity) | The IPsec integrity algorithm (Phase 2) for the secondary connection. Default: SHA256 | `string` | `"SHA256"` | no |
| <a name="input_azure_secondary_connection_pfs_group"></a> [azure\_secondary\_connection\_pfs\_group](#input\_azure\_secondary\_connection\_pfs\_group) | The Perfect Forward Secrecy (PFS) group used in IPsec Phase 2 for the secondary connection. Default: PFS14 (Because Azure doesn't support PFS15) | `string` | `"PFS14"` | no |
| <a name="input_azure_secondary_connection_sa_lifetime"></a> [azure\_secondary\_connection\_sa\_lifetime](#input\_azure\_secondary\_connection\_sa\_lifetime) | The Security Association (SA) lifetime in seconds for the secondary connection. Default: 19800 | `number` | `19800` | no |
| <a name="input_azure_vnet_name"></a> [azure\_vnet\_name](#input\_azure\_vnet\_name) | The name of the Virtual Network to Build / Use | `string` | `null` | no |
| <a name="input_azure_vng_subnet_range"></a> [azure\_vng\_subnet\_range](#input\_azure\_vng\_subnet\_range) | CIDR range for the Subnet in the Virtual Network, if we're building it. | `string` | `null` | no |
| <a name="input_azure_vng_vnet_range"></a> [azure\_vng\_vnet\_range](#input\_azure\_vng\_vnet\_range) | CIDR range for the Virtual Network, if we're building it. | `string` | `null` | no |
| <a name="input_baseurl"></a> [baseurl](#input\_baseurl) | Cato API base URL | `string` | `"https://api.catonetworks.com/api/v1/graphql2"` | no |
| <a name="input_build_azure_resource_group"></a> [build\_azure\_resource\_group](#input\_build\_azure\_resource\_group) | Whether or not to build a new resource group for this deployment | `bool` | n/a | yes |
| <a name="input_build_azure_vng_vnet"></a> [build\_azure\_vng\_vnet](#input\_build\_azure\_vng\_vnet) | Whether or not to build a new virtual network for this deployment | `bool` | n/a | yes |
| <a name="input_cato_authMessage_cipher"></a> [cato\_authMessage\_cipher](#input\_cato\_authMessage\_cipher) | Cato Phase 2 ciphers.  The SA tunnel encryption method. Note: For situations where GCM isn’t supported for the INIT phase, <br/>  we recommend that you use the CBC algorithm for the INIT phase, and GCM for AUTH<br/>  Valid options are: <br/>    AES\_CBC\_128<br/>    AES\_CBC\_256<br/>    AES\_GCM\_128<br/>    AES\_GCM\_256<br/>    AUTOMATIC<br/>    DES3\_CBC<br/>    NONE<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_authMessage_dhGroup"></a> [cato\_authMessage\_dhGroup](#input\_cato\_authMessage\_dhGroup) | Cato Phase 2 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is <br/>   the corresponding prime modulus size in bits<br/>   Valid Options are: <br/>    AUTOMATIC<br/>    DH\_14\_MODP2048<br/>    DH\_15\_MODP3072<br/>    DH\_16\_MODP4096<br/>    DH\_19\_ECP256<br/>    DH\_2\_MODP1024<br/>    DH\_20\_ECP384<br/>    DH\_21\_ECP521<br/>    DH\_5\_MODP1536<br/>    NONE<br/>    Default to DH\_14\_MODP2048 | `string` | `"DH_14_MODP2048"` | no |
| <a name="input_cato_authMessage_integrity"></a> [cato\_authMessage\_integrity](#input\_cato\_authMessage\_integrity) | Cato Phase 2 Hashing Algorithm.  The algorithm used to verify the integrity and authenticity of IPsec packets<br/>    Valid Options are: <br/>    AUTOMATIC<br/>    MD5<br/>    NONE<br/>    SHA1<br/>    SHA256<br/>    SHA384<br/>    SHA512<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_bgp_asn"></a> [cato\_bgp\_asn](#input\_cato\_bgp\_asn) | The BGP Autonomous System Number for the Cato PoPs. Required if azure\_enable\_bgp is true. | `number` | `65001` | no |
| <a name="input_cato_connectionMode"></a> [cato\_connectionMode](#input\_cato\_connectionMode) | Cato Connection Mode.  Determines the protocol for establishing the Security Association (SA) Tunnel. <br/>  Valid values are: Responder-Only Mode: Cato Cloud only responds to incoming requests by the initiator (e.g. a Firewall device) to establish a security association. <br/>  Bidirectional Mode: Both Cato Cloud and the peer device on customer site can initiate the IPSec SA establishment.<br/>  Valid Options are: <br/>    BIDIRECTIONAL<br/>    RESPONDER\_ONLY<br/>    Default to BIDIRECTIONAL | `string` | `"BIDIRECTIONAL"` | no |
| <a name="input_cato_identificationType"></a> [cato\_identificationType](#input\_cato\_identificationType) | Cato Identification Type.  The authentication identification type used for SA authentication. When using “BIDIRECTIONAL”, it is set to “IPv4” by default. <br/>  Other methods are available in Responder mode only. <br/>  Valid Options are: <br/>    EMAIL<br/>    FQDN<br/>    IPV4<br/>    KEY\_ID<br/>    Default to IPV4 | `string` | `"IPV4"` | no |
| <a name="input_cato_initMessage_cipher"></a> [cato\_initMessage\_cipher](#input\_cato\_initMessage\_cipher) | Cato Phase 1 ciphers.  The SA tunnel encryption method. Note: For situations where GCM isn’t supported for the INIT phase, <br/>  we recommend that you use the CBC algorithm for the INIT phase, and GCM for AUTH<br/>  Valid options are: <br/>    AES\_CBC\_128<br/>    AES\_CBC\_256<br/>    AES\_GCM\_128<br/>    AES\_GCM\_256<br/>    AUTOMATIC<br/>    DES3\_CBC<br/>    NONE<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_initMessage_dhGroup"></a> [cato\_initMessage\_dhGroup](#input\_cato\_initMessage\_dhGroup) | Cato Phase 1 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is <br/>   the corresponding prime modulus size in bits<br/>   Valid Options are: <br/>    AUTOMATIC<br/>    DH\_14\_MODP2048<br/>    DH\_15\_MODP3072<br/>    DH\_16\_MODP4096<br/>    DH\_19\_ECP256<br/>    DH\_2\_MODP1024<br/>    DH\_20\_ECP384<br/>    DH\_21\_ECP521<br/>    DH\_5\_MODP1536<br/>    NONE<br/>    Default to DH\_14\_MODP2048 | `string` | `"DH_14_MODP2048"` | no |
| <a name="input_cato_initMessage_integrity"></a> [cato\_initMessage\_integrity](#input\_cato\_initMessage\_integrity) | Cato Phase 1 Hashing Algorithm.  The algorithm used to verify the integrity and authenticity of IPsec packets<br/>   Valid Options are: <br/>    AUTOMATIC<br/>    MD5<br/>    NONE<br/>    SHA1<br/>    SHA256<br/>    SHA384<br/>    SHA512<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_initMessage_prf"></a> [cato\_initMessage\_prf](#input\_cato\_initMessage\_prf) | Cato Phase 1 Hashing Algorithm for The Pseudo-random function (PRF) used to derive the cryptographic keys used in the SA establishment process. <br/>  Valid Options are: <br/>    AUTOMATIC<br/>    MD5<br/>    NONE<br/>    SHA1<br/>    SHA256<br/>    SHA384<br/>    SHA512<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_local_networks"></a> [cato\_local\_networks](#input\_cato\_local\_networks) | If we aren't using BGP, we will need a list of CIDRs which live behind Cato<br/>  for more information https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range <br/>  Default: ["10.41.0.0/16", "10.254.254.0/24"] | `list(string)` | <pre>[<br/>  "10.41.0.0/16",<br/>  "10.254.254.0/24"<br/>]</pre> | no |
| <a name="input_cato_primary_bgp_advertise_all"></a> [cato\_primary\_bgp\_advertise\_all](#input\_cato\_primary\_bgp\_advertise\_all) | Cato Primary BGP Advertise All | `bool` | `true` | no |
| <a name="input_cato_primary_bgp_advertise_default_route"></a> [cato\_primary\_bgp\_advertise\_default\_route](#input\_cato\_primary\_bgp\_advertise\_default\_route) | Cato Primary BGP Advertise Default Route | `bool` | `false` | no |
| <a name="input_cato_primary_bgp_advertise_summary_route"></a> [cato\_primary\_bgp\_advertise\_summary\_route](#input\_cato\_primary\_bgp\_advertise\_summary\_route) | Cato Primary BGP Advertise Summary Route | `bool` | `false` | no |
| <a name="input_cato_primary_bgp_bfd_multiplier"></a> [cato\_primary\_bgp\_bfd\_multiplier](#input\_cato\_primary\_bgp\_bfd\_multiplier) | Cato Primary BGP BFD Multiplier | `number` | `5` | no |
| <a name="input_cato_primary_bgp_bfd_receive_interval"></a> [cato\_primary\_bgp\_bfd\_receive\_interval](#input\_cato\_primary\_bgp\_bfd\_receive\_interval) | Cato Primary BGP BFD Receive Interval | `number` | `1000` | no |
| <a name="input_cato_primary_bgp_bfd_transmit_interval"></a> [cato\_primary\_bgp\_bfd\_transmit\_interval](#input\_cato\_primary\_bgp\_bfd\_transmit\_interval) | Cato Primary BGP BFD Transmit Interval | `number` | `1000` | no |
| <a name="input_cato_primary_bgp_default_action"></a> [cato\_primary\_bgp\_default\_action](#input\_cato\_primary\_bgp\_default\_action) | Cato Primary BGP Default Action | `string` | `"ACCEPT"` | no |
| <a name="input_cato_primary_bgp_metric"></a> [cato\_primary\_bgp\_metric](#input\_cato\_primary\_bgp\_metric) | Metric for the primary Cato BGP peer to influence route preference. | `number` | `100` | no |
| <a name="input_cato_primary_bgp_peer_name"></a> [cato\_primary\_bgp\_peer\_name](#input\_cato\_primary\_bgp\_peer\_name) | Cato Primary BGP Peer Name | `string` | `null` | no |
| <a name="input_cato_secondary_bgp_advertise_all"></a> [cato\_secondary\_bgp\_advertise\_all](#input\_cato\_secondary\_bgp\_advertise\_all) | Cato Secondary BGP Advertise All | `bool` | `true` | no |
| <a name="input_cato_secondary_bgp_advertise_default_route"></a> [cato\_secondary\_bgp\_advertise\_default\_route](#input\_cato\_secondary\_bgp\_advertise\_default\_route) | Cato Secondary BGP Advertise Default Route | `bool` | `false` | no |
| <a name="input_cato_secondary_bgp_advertise_summary_route"></a> [cato\_secondary\_bgp\_advertise\_summary\_route](#input\_cato\_secondary\_bgp\_advertise\_summary\_route) | Cato Secondary BGP Advertise Summary Route | `bool` | `false` | no |
| <a name="input_cato_secondary_bgp_bfd_multiplier"></a> [cato\_secondary\_bgp\_bfd\_multiplier](#input\_cato\_secondary\_bgp\_bfd\_multiplier) | Cato Secondary BGP BFD Multiplier | `number` | `5` | no |
| <a name="input_cato_secondary_bgp_bfd_receive_interval"></a> [cato\_secondary\_bgp\_bfd\_receive\_interval](#input\_cato\_secondary\_bgp\_bfd\_receive\_interval) | Cato Secondary BGP BFD Receive Interval | `number` | `1000` | no |
| <a name="input_cato_secondary_bgp_bfd_transmit_interval"></a> [cato\_secondary\_bgp\_bfd\_transmit\_interval](#input\_cato\_secondary\_bgp\_bfd\_transmit\_interval) | Cato Secondary BGP BFD Transmit Interval | `number` | `1000` | no |
| <a name="input_cato_secondary_bgp_default_action"></a> [cato\_secondary\_bgp\_default\_action](#input\_cato\_secondary\_bgp\_default\_action) | Cato Secondary BGP Default Action | `string` | `"ACCEPT"` | no |
| <a name="input_cato_secondary_bgp_metric"></a> [cato\_secondary\_bgp\_metric](#input\_cato\_secondary\_bgp\_metric) | Metric for the secondary Cato BGP peer to influence route preference. | `number` | `200` | no |
| <a name="input_cato_secondary_bgp_peer_name"></a> [cato\_secondary\_bgp\_peer\_name](#input\_cato\_secondary\_bgp\_peer\_name) | Cato Secondary BGP Peer Name | `string` | `null` | no |
| <a name="input_downstream_bw"></a> [downstream\_bw](#input\_downstream\_bw) | Downstream bandwidth in Mbps | `number` | n/a | yes |
| <a name="input_license_bw"></a> [license\_bw](#input\_license\_bw) | The license bandwidth number for the cato site, specifying bandwidth ONLY applies for pooled licenses.  For a standard site license that is not pooled, leave this value null. Must be a number greater than 0 and an increment of 10. | `string` | `null` | no |
| <a name="input_license_id"></a> [license\_id](#input\_license\_id) | The license ID for the Cato vSocket of license type CATO\_SITE, CATO\_SSE\_SITE, CATO\_PB, CATO\_PB\_SSE.  Example License ID value: 'abcde123-abcd-1234-abcd-abcde1234567'.  Note that licenses are for commercial accounts, and not supported for trial accounts. | `string` | `null` | no |
| <a name="input_native_network_range"></a> [native\_network\_range](#input\_native\_network\_range) | Native network range for the IPSec site | `string` | n/a | yes |
| <a name="input_primary_cato_pop_ip"></a> [primary\_cato\_pop\_ip](#input\_primary\_cato\_pop\_ip) | The IP address of the primary Cato POP | `string` | n/a | yes |
| <a name="input_primary_connection_shared_key"></a> [primary\_connection\_shared\_key](#input\_primary\_connection\_shared\_key) | Primary connection shared key | `string` | `null` | no |
| <a name="input_primary_destination_type"></a> [primary\_destination\_type](#input\_primary\_destination\_type) | The destination type of the IPsec tunnel | `string` | `null` | no |
| <a name="input_primary_pop_location_id"></a> [primary\_pop\_location\_id](#input\_primary\_pop\_location\_id) | Primary tunnel POP location ID | `string` | `null` | no |
| <a name="input_primary_private_cato_ip"></a> [primary\_private\_cato\_ip](#input\_primary\_private\_cato\_ip) | The BGP peering IP address for the CatoPOP (APIPA). Required if azure\_enable\_bgp is true.<br/>  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255. | `string` | `null` | no |
| <a name="input_primary_private_site_ip"></a> [primary\_private\_site\_ip](#input\_primary\_private\_site\_ip) | The BGP peering IP address for the Azure VPN Gateway (APIPA). Required if azure\_enable\_bgp is true.<br/>  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255. | `string` | `null` | no |
| <a name="input_secondary_cato_pop_ip"></a> [secondary\_cato\_pop\_ip](#input\_secondary\_cato\_pop\_ip) | The IP address of the secondary Cato POP | `string` | n/a | yes |
| <a name="input_secondary_connection_shared_key"></a> [secondary\_connection\_shared\_key](#input\_secondary\_connection\_shared\_key) | Secondary connection shared key | `string` | `null` | no |
| <a name="input_secondary_destination_type"></a> [secondary\_destination\_type](#input\_secondary\_destination\_type) | The destination type of the IPsec tunnel | `string` | `null` | no |
| <a name="input_secondary_pop_location_id"></a> [secondary\_pop\_location\_id](#input\_secondary\_pop\_location\_id) | Secondary tunnel POP location ID | `string` | `null` | no |
| <a name="input_secondary_private_cato_ip"></a> [secondary\_private\_cato\_ip](#input\_secondary\_private\_cato\_ip) | The BGP peering IP address for the CatoPOP (APIPA). Required if azure\_enable\_bgp is true.<br/>  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255. | `string` | `null` | no |
| <a name="input_secondary_private_site_ip"></a> [secondary\_private\_site\_ip](#input\_secondary\_private\_site\_ip) | The BGP peering IP address for the Azure VPN Gateway (APIPA). Required if azure\_enable\_bgp is true.<br/>  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255. | `string` | `null` | no |
| <a name="input_site_description"></a> [site\_description](#input\_site\_description) | Description of the IPSec site | `string` | n/a | yes |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | Site location which is used by the Cato Socket to connect to the closest Cato PoP. If not specified, the location will be derived from the Azure region dynamicaly. | <pre>object({<br/>    city         = string<br/>    country_code = string<br/>    state_code   = string<br/>    timezone     = string<br/>  })</pre> | <pre>{<br/>  "city": null,<br/>  "country_code": null,<br/>  "state_code": null,<br/>  "timezone": null<br/>}</pre> | no |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | Name of the IPSec site | `string` | n/a | yes |
| <a name="input_site_type"></a> [site\_type](#input\_site\_type) | The type of the site | `string` | `"CLOUD_DC"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of Keys & Values to describe the infrastructure<br/>  Example: <br/>  { <br/>  terraform = "true"<br/>  built\_by = "Your Name"<br/>  } | `map(string)` | `{}` | no |
| <a name="input_token"></a> [token](#input\_token) | Cato API token | `string` | n/a | yes |
| <a name="input_upstream_bw"></a> [upstream\_bw](#input\_upstream\_bw) | Upstream bandwidth in Mbps | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_resource_group_name"></a> [azure\_resource\_group\_name](#output\_azure\_resource\_group\_name) | The name of the Azure Resource Group created. |
| <a name="output_azure_virtual_network_name"></a> [azure\_virtual\_network\_name](#output\_azure\_virtual\_network\_name) | The name of the Azure Virtual Network. |
| <a name="output_cato_license_site"></a> [cato\_license\_site](#output\_cato\_license\_site) | n/a |
| <a name="output_cato_site_id"></a> [cato\_site\_id](#output\_cato\_site\_id) | The ID of the created Cato IPsec site. |
| <a name="output_primary_connection_shared_key"></a> [primary\_connection\_shared\_key](#output\_primary\_connection\_shared\_key) | The shared key for the primary VPN connection. This is sensitive. |
| <a name="output_primary_local_network_gateway_name"></a> [primary\_local\_network\_gateway\_name](#output\_primary\_local\_network\_gateway\_name) | Name of the primary local network gateway representing the Cato PoP. |
| <a name="output_secondary_connection_shared_key"></a> [secondary\_connection\_shared\_key](#output\_secondary\_connection\_shared\_key) | The shared key for the secondary VPN connection. This is sensitive. |
| <a name="output_secondary_local_network_gateway_name"></a> [secondary\_local\_network\_gateway\_name](#output\_secondary\_local\_network\_gateway\_name) | Name of the secondary local network gateway representing the Cato PoP. |
| <a name="output_site_location"></a> [site\_location](#output\_site\_location) | n/a |
| <a name="output_vpn_gateway_id"></a> [vpn\_gateway\_id](#output\_vpn\_gateway\_id) | The ID of the VPN Gateway |
| <a name="output_vpn_gateway_primary_public_ip"></a> [vpn\_gateway\_primary\_public\_ip](#output\_vpn\_gateway\_primary\_public\_ip) | The primary public IP address of the Azure VPN Gateway. |
| <a name="output_vpn_gateway_secondary_public_ip"></a> [vpn\_gateway\_secondary\_public\_ip](#output\_vpn\_gateway\_secondary\_public\_ip) | The secondary public IP address of the Azure VPN Gateway (for active-active configurations). |
<!-- END_TF_DOCS -->