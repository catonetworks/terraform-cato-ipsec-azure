# CATO IPSec Azure Terraform module

Terraform module which creates an IPsec site in the Cato Management Application (CMA), and a primary and secondary IPsec tunnel from Azure to the Cato platform.

## List of Resources:
- azurerm_public_ip (vpn_gateway_pip)
- azurerm_local_network_gateway (cato_pop_primary)
- azurerm_local_network_gateway (cato_pop_secondary)
- azurerm_virtual_network_gateway_connection (cato_connection_primary)
- azurerm_virtual_network_gateway_connection (cato_connection_secondary)
- azurerm_virtual_network_gateway (vpn_gateway)
- cato_ipsec_site

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

