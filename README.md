# CATO IPSec Azure Terraform module

Terraform module which creates an IPsec site in the Cato Management Application (CMA), and a primary and secondary IPsec tunnel from Azure to the Cato platform.

## NOTE
- For help with finding exact sytax to match site location for city, state_name, country_name and timezone, please refer to the [cato_siteLocation data source](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/siteLocation).
- For help with finding a license id to assign, please refer to the [cato_licensingInfo data source](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/licensingInfo).

## Usage

<details>
<summary>Required Azure resources for IPSec module</summary>

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azure-rg" {
  location = var.az_location
  name     = replace(replace("Your-site-name-VNET", "-", ""), " ", "_")
}

resource "azurerm_availability_set" "availability-set" {
  location                     = var.az_location
  name                         = replace(replace("Your-site-name-availabilitySet", "-", "_"), " ", "_")
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  resource_group_name          = azurerm_resource_group.azure-rg.name
  depends_on = [
    azurerm_resource_group.azure-rg
  ]
}

## Create Network and Subnets
resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.native_network_range]
  location            = var.az_location
  name                = replace(replace("Your-site-name-vsNet", "-", "_"), " ", "_")
  resource_group_name = azurerm_resource_group.azure-rg.name
  depends_on = [
    azurerm_resource_group.azure-rg
  ]
}

resource "azurerm_subnet" "subnet" {
  address_prefixes     = [var.native_network_range]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.azure-rg.name
  virtual_network_name = replace(replace("Your-site-name-vsNet", "-", "_"), " ", "_")
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}
```
</details>

Example module usage:

```
provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

module "ipsec-azure" {
  source                      = "catonetworks/ipsec-azure/cato"
  token                       = var.cato_token
  account_id                  = var.account_id
  az_location                 = "East US"
  resource_group_name         = replace(replace("${var.site_name}-VNET", "-", ""), " ", "_")
  vnet_name                   = replace(replace("${var.site_name}-vsNet", "-", "_"), " ", "_")
  gateway_subnet_id           = azurerm_subnet.subnet.id
  vpn_gateway_name            = "my-azure-vpn-gateway"
  local_network_gateway_name  = "cato-local-network-gateway"
  site_name                   = "My-Azure-Cato-IPSec-Site-8"
  site_description            = "TestTFAzureIPSec8"
  native_network_range        = "172.16.0.0/24"
  primary_private_cato_ip     = "169.1.1.1"
  primary_private_site_ip     = "169.1.1.2"
  primary_cato_pop_ip         = "11.22.33.44" # Your Primary Cato IP
  primary_public_cato_ip_id   = "31511" # Your Primary Cato IP ID
  secondary_private_cato_ip   = "169.2.1.1"
  secondary_private_site_ip   = "169.2.1.2"
  secondary_cato_pop_ip       = "11.22.33.55" # Your Secondary Cato IP ID
  secondary_public_cato_ip_id = "31512" # Your Secondary Cato IP ID
  downstream_bw               = 100
  upstream_bw                 = 100
  site_location = {
    city         = "New York City"
    country_code = "US"
    state_code   = "US-NY"
    timezone     = "America/New_York"
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.1.0 |
| <a name="provider_cato"></a> [cato](#provider\_cato) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_local_network_gateway.cato_pop_primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_local_network_gateway.cato_pop_secondary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_public_ip.vpn_gateway_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_network_gateway.vpn_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_connection.cato_connection_primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [azurerm_virtual_network_gateway_connection.cato_connection_secondary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [cato_ipsec_site.ipsec-site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/ipsec_site) | resource |
| [cato_license.license](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/license) | resource |
| [null_resource.update_dh_group](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.shared_key_primary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.shared_key_secondary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_location"></a> [az\_location](#input\_az\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_downstream_bw"></a> [downstream\_bw](#input\_downstream\_bw) | Downstream bandwidth in Mbps | `number` | n/a | yes |
| <a name="input_gateway_subnet_id"></a> [gateway\_subnet\_id](#input\_gateway\_subnet\_id) | The id of the gateway subnet | `string` | n/a | yes |
| <a name="input_license_bw"></a> [license\_bw](#input\_license\_bw) | The license bandwidth number for the cato site, specifying bandwidth ONLY applies for pooled licenses.  For a standard site license that is not pooled, leave this value null. Must be a number greater than 0 and an increment of 10. | `string` | `null` | no |
| <a name="input_license_id"></a> [license\_id](#input\_license\_id) | The license ID for the Cato vSocket of license type CATO\_SITE, CATO\_SSE\_SITE, CATO\_PB, CATO\_PB\_SSE.  Example License ID value: 'abcde123-abcd-1234-abcd-abcde1234567'.  Note that licenses are for commercial accounts, and not supported for trial accounts. | `string` | `null` | no |
| <a name="input_local_network_gateway_name"></a> [local\_network\_gateway\_name](#input\_local\_network\_gateway\_name) | The name of the local network gateway | `string` | n/a | yes |
| <a name="input_native_network_range"></a> [native\_network\_range](#input\_native\_network\_range) | Native network range for the IPSec site | `string` | n/a | yes |
| <a name="input_primary_cato_pop_ip"></a> [primary\_cato\_pop\_ip](#input\_primary\_cato\_pop\_ip) | The IP address of the primary Cato POP | `string` | n/a | yes |
| <a name="input_primary_connection_shared_key"></a> [primary\_connection\_shared\_key](#input\_primary\_connection\_shared\_key) | Primary connection shared key | `string` | `null` | no |
| <a name="input_primary_destination_type"></a> [primary\_destination\_type](#input\_primary\_destination\_type) | The destination type of the IPsec tunnel | `string` | `null` | no |
| <a name="input_primary_pop_location_id"></a> [primary\_pop\_location\_id](#input\_primary\_pop\_location\_id) | Primary tunnel POP location ID | `string` | `null` | no |
| <a name="input_primary_private_cato_ip"></a> [primary\_private\_cato\_ip](#input\_primary\_private\_cato\_ip) | Private IP address of the Cato side for the primary tunnel | `string` | n/a | yes |
| <a name="input_primary_private_site_ip"></a> [primary\_private\_site\_ip](#input\_primary\_private\_site\_ip) | Private IP address of the site side for the primary tunnel | `string` | n/a | yes |
| <a name="input_primary_public_cato_ip_id"></a> [primary\_public\_cato\_ip\_id](#input\_primary\_public\_cato\_ip\_id) | Public IP address ID of the Cato side for the primary tunnel | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_secondary_cato_pop_ip"></a> [secondary\_cato\_pop\_ip](#input\_secondary\_cato\_pop\_ip) | The IP address of the secondary Cato POP | `string` | n/a | yes |
| <a name="input_secondary_connection_shared_key"></a> [secondary\_connection\_shared\_key](#input\_secondary\_connection\_shared\_key) | Secondary connection shared key | `string` | `null` | no |
| <a name="input_secondary_destination_type"></a> [secondary\_destination\_type](#input\_secondary\_destination\_type) | The destination type of the IPsec tunnel | `string` | `null` | no |
| <a name="input_secondary_pop_location_id"></a> [secondary\_pop\_location\_id](#input\_secondary\_pop\_location\_id) | Secondary tunnel POP location ID | `string` | `null` | no |
| <a name="input_secondary_private_cato_ip"></a> [secondary\_private\_cato\_ip](#input\_secondary\_private\_cato\_ip) | Private IP address of the Cato side for the secondary tunnel | `string` | n/a | yes |
| <a name="input_secondary_private_site_ip"></a> [secondary\_private\_site\_ip](#input\_secondary\_private\_site\_ip) | Private IP address of the site side for the secondary tunnel | `string` | n/a | yes |
| <a name="input_secondary_public_cato_ip_id"></a> [secondary\_public\_cato\_ip\_id](#input\_secondary\_public\_cato\_ip\_id) | Public IP address ID of the Cato side for the secondary tunnel | `string` | n/a | yes |
| <a name="input_site_description"></a> [site\_description](#input\_site\_description) | Description of the IPSec site | `string` | n/a | yes |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | n/a | <pre>object({<br/>    city         = string<br/>    country_code = string<br/>    state_code   = string<br/>    timezone     = string<br/>  })</pre> | n/a | yes |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | Name of the IPSec site | `string` | n/a | yes |
| <a name="input_site_type"></a> [site\_type](#input\_site\_type) | The type of the site | `string` | `"CLOUD_DC"` | no |
| <a name="input_upstream_bw"></a> [upstream\_bw](#input\_upstream\_bw) | Upstream bandwidth in Mbps | `number` | n/a | yes |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the Virtual Network | `string` | n/a | yes |
| <a name="input_vpn_gateway_name"></a> [vpn\_gateway\_name](#input\_vpn\_gateway\_name) | The name of the VPN gateway | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cato_license_site"></a> [cato\_license\_site](#output\_cato\_license\_site) | n/a |
| <a name="output_site_id"></a> [site\_id](#output\_site\_id) | ID of the created Cato IPSec site |
| <a name="output_vpn_gateway_id"></a> [vpn\_gateway\_id](#output\_vpn\_gateway\_id) | The ID of the VPN Gateway |
| <a name="output_vpn_gateway_public_ip"></a> [vpn\_gateway\_public\_ip](#output\_vpn\_gateway\_public\_ip) | The public IP address of the VPN Gateway |
<!-- END_TF_DOCS -->