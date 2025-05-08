# Create 2 allocated IPs in Cato Management Application(CMA), Get IDs
# Public IP for the VPN Gateway
resource "azurerm_public_ip" "vpn_gateway_pip" {
  name                = "${var.vpn_gateway_name}-publicip"
  location            = var.az_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# VPN Gateway

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = var.vpn_gateway_name
  location            = var.az_location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
}

# Local Network Gateway representing the Cato PoP

resource "azurerm_local_network_gateway" "cato_pop_primary" {
  name                = "${var.local_network_gateway_name}-primary"
  location            = var.az_location
  resource_group_name = var.resource_group_name
  gateway_address     = var.primary_cato_pop_ip
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_local_network_gateway" "cato_pop_secondary" {
  name                = "${var.local_network_gateway_name}-secondary"
  location            = var.az_location
  resource_group_name = var.resource_group_name
  gateway_address     = var.secondary_cato_pop_ip
  address_space       = ["10.0.0.0/8"]
}

# Shared key for the VPN connection

resource "random_password" "shared_key_primary" {
  length  = 32
  special = true
}

resource "random_password" "shared_key_secondary" {
  length  = 32
  special = true
}

# VPN Connection to Cato

resource "azurerm_virtual_network_gateway_connection" "cato_connection_primary" {
  name                = "${var.site_name}--connection-primary"
  location            = var.az_location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.cato_pop_primary.id

  shared_key = var.primary_connection_shared_key == null ? random_password.shared_key_primary.result : var.primary_connection_shared_key
}

resource "azurerm_virtual_network_gateway_connection" "cato_connection_secondary" {
  name                = "${var.site_name}-connection-secondary"
  location            = var.az_location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.cato_pop_secondary.id

  shared_key = var.secondary_connection_shared_key == null ? random_password.shared_key_secondary.result : var.secondary_connection_shared_key
}


# Create Cato ipsec site and tunnels
resource "cato_ipsec_site" "ipsec-site" {
  name                 = var.site_name
  site_type            = var.site_type
  description          = var.site_description
  native_network_range = var.native_network_range
  site_location        = var.site_location
  ipsec = {
    primary = {
      destination_type  = var.primary_destination_type
      public_cato_ip_id = var.primary_public_cato_ip_id
      pop_location_id   = var.primary_pop_location_id
      tunnels = [
        {
          public_site_ip  = azurerm_public_ip.vpn_gateway_pip.ip_address
          private_cato_ip = var.primary_private_cato_ip
          private_site_ip = var.primary_private_site_ip
          psk             = var.primary_connection_shared_key == null ? random_password.shared_key_primary.result : var.primary_connection_shared_key
          last_mile_bw = {
            downstream = var.downstream_bw
            upstream   = var.upstream_bw
          }
        }
      ]
    }
    secondary = {
      destination_type  = var.secondary_destination_type
      public_cato_ip_id = var.secondary_public_cato_ip_id
      pop_location_id   = var.secondary_pop_location_id
      tunnels = [
        {
          public_site_ip  = azurerm_public_ip.vpn_gateway_pip.ip_address
          private_cato_ip = var.secondary_private_cato_ip
          private_site_ip = var.secondary_private_site_ip
          psk             = var.secondary_connection_shared_key == null ? random_password.shared_key_secondary.result : var.secondary_connection_shared_key
          last_mile_bw = {
            downstream = var.downstream_bw
            upstream   = var.upstream_bw
          }
        }
      ]
    }
  }
}

resource "null_resource" "update_dh_group" {
  depends_on = [cato_ipsec_site.ipsec-site]
  lifecycle {
    ignore_changes = all
  }
  triggers = {
    site_id = cato_ipsec_site.ipsec-site.id
  }

  provisioner "local-exec" {
    command = <<EOF
curl -k -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "x-API-Key: ${var.token}" \
  '${var.baseurl}' \
  --data '{
    "query": "mutation siteUpdateIpsecIkeV2SiteGeneralDetails($siteId: ID!, $updateIpsecIkeV2SiteGeneralDetailsInput: UpdateIpsecIkeV2SiteGeneralDetailsInput!, $accountId: ID!) { site(accountId: $accountId) { updateIpsecIkeV2SiteGeneralDetails(siteId: $siteId, input: $updateIpsecIkeV2SiteGeneralDetailsInput) { siteId localId } } }",
    "variables": {
      "accountId": ${var.account_id},
      "siteId": "${cato_ipsec_site.ipsec-site.id}",
      "updateIpsecIkeV2SiteGeneralDetailsInput": {
        "initMessage": {
          "dhGroup": "DH_2_MODP1024"
        }
      }
    },
    "operationName": "siteUpdateIpsecIkeV2SiteGeneralDetails"
  }'
EOF
  }
}

resource "cato_license" "license" {
  depends_on = [cato_ipsec_site.ipsec-site]
  count      = var.license_id == null ? 0 : 1
  site_id    = cato_ipsec_site.azure-site.id
  license_id = var.license_id
  bw         = var.license_bw == null ? null : var.license_bw
}
