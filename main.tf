# Create resource group conditionally 
resource "azurerm_resource_group" "network_resource_group" {
  count    = var.build_azure_resource_group ? 1 : 0
  name     = var.azure_resource_group_name
  location = var.az_location
}

# Create virtual network conditionally 
resource "azurerm_virtual_network" "vng_virtual_network" {
  count               = var.build_azure_vng_vnet ? 1 : 0
  name                = var.azure_vnet_name == null ? "${var.site_name}-vng-vnet" : var.azure_vnet_name
  address_space       = [var.azure_vng_vnet_range]
  location            = var.az_location
  resource_group_name = local.resource_group_name
}

# Create gateway subnet (required for VPN Gateway) Conditionally 
resource "azurerm_subnet" "vng_subnet" {
  count                = var.build_azure_vng_vnet ? 1 : 0
  name                 = "GatewaySubnet" #it is mandatory that the associated subnet is named GatewaySubnet
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [var.azure_vng_subnet_range]
}

# Public IP for the VPN Gateway
resource "azurerm_public_ip" "vpn_gateway_primary" {
  name                = "${var.site_name}-primary-publicip"
  location            = var.az_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
# Secondary Public IP in case we do BGP Active/Active
resource "azurerm_public_ip" "vpn_gateway_secondary" {
  count               = var.azure_enable_activeactive ? 1 : 0
  name                = "${var.site_name}-secondary-publicip"
  location            = var.az_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# VPN Gateway

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "${var.site_name}-vpn-gateway"
  location            = var.az_location
  resource_group_name = local.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"


  # If we Do BGP, we need to be active / active and the SKU needs to support this. 
  active_active = var.azure_enable_activeactive
  enable_bgp    = var.azure_enable_bgp
  sku           = var.azure_enable_bgp || var.azure_enable_activeactive ? "VpnGw2" : "VpnGw1"

  # Primary IP configuration, always created
  ip_configuration {
    name                          = "${var.site_name}-primary-vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_primary.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.azure_gateway_subnet_id == null ? azurerm_subnet.vng_subnet[0].id : var.azure_gateway_subnet_id
  }

  # Secondary IP configuration, only for active-active/BGP mode
  ip_configuration {
      name                          = "${var.site_name}-secondary-vnetGatewayConfig"
      public_ip_address_id          = azurerm_public_ip.vpn_gateway_secondary[0].id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.azure_gateway_subnet_id == null ? azurerm_subnet.vng_subnet[0].id : var.azure_gateway_subnet_id
  }

  # --- CONDITIONAL BGP ---
  # BGP settings, only for active-active/BGP mode
  dynamic "bgp_settings" {
    for_each = var.azure_enable_bgp ? [1] : []
    content {
      asn = var.azure_bgp_asn #Azure's ASN

      peering_addresses {
        ip_configuration_name = "${var.site_name}-primary-vnetGatewayConfig"
        apipa_addresses       = [var.azure_bgp_peering_address_0]
      }
      peering_addresses {
        ip_configuration_name = "${var.site_name}-secondary-vnetGatewayConfig"
        apipa_addresses       = [var.azure_bgp_peering_address_1]
      }
    }
  }
  tags = var.tags

}

# Local Network Gateway representing the Cato PoP

resource "azurerm_local_network_gateway" "cato_pop_primary" {
  name                = "${var.site_name}-primary"
  location            = var.az_location
  resource_group_name = local.resource_group_name
  gateway_address     = var.primary_cato_pop_ip
  # When BGP is off, this static route is used. When BGP is on, it can act as a fallback.
  address_space = var.azure_enable_bgp ? [] : var.cato_local_networks

  # --- CONDITIONAL BGP ---
  dynamic "bgp_settings" {
    for_each = var.azure_enable_bgp ? [1] : []
    content {
      asn                 = var.cato_bgp_asn
      bgp_peering_address = var.primary_private_cato_ip
    }
  }
  # --- END CONDITIONAL BGP ---
  tags = var.tags
}

resource "azurerm_local_network_gateway" "cato_pop_secondary" {
  name                = "${var.site_name}-secondary"
  location            = var.az_location
  resource_group_name = local.resource_group_name
  gateway_address     = var.secondary_cato_pop_ip
  # When BGP is off, this static route is used. When BGP is on, it can act as a fallback.
  address_space = var.azure_enable_bgp ? [] : var.cato_local_networks
  # --- CONDITIONAL BGP ---
  dynamic "bgp_settings" {
    for_each = var.azure_enable_bgp ? [1] : []
    content {
      asn                 = var.cato_bgp_asn
      bgp_peering_address = var.secondary_private_cato_ip
    }
  }
  # --- END CONDITIONAL BGP ---
  tags = var.tags
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
  resource_group_name = local.resource_group_name

  type                       = "IPsec"
  connection_protocol        = var.azure_ipsec_version
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.cato_pop_primary.id

  # --- CONDITIONAL BGP ---
  enable_bgp = var.azure_enable_bgp
  # --- END CONDITIONAL BGP ---

  ipsec_policy {
    # IKE Phase 1 Parameters
    ike_encryption = var.azure_primary_connection_ike_encryption
    ike_integrity  = var.azure_primary_connection_ike_integrity
    dh_group       = var.azure_primary_connection_dh_group


    # IPsec Phase 2 Parameters
    ipsec_encryption = var.azure_primary_connection_ipsec_encryption
    ipsec_integrity  = var.azure_primary_connection_ipsec_integrity
    pfs_group        = var.azure_primary_connection_pfs_group

    # Security Association (SA) Lifetimes
    sa_lifetime = var.azure_primary_connection_sa_lifetime
  }


  shared_key = var.primary_connection_shared_key == null ? random_password.shared_key_primary.result : var.primary_connection_shared_key
}

resource "azurerm_virtual_network_gateway_connection" "cato_connection_secondary" {
  name                = "${var.site_name}-connection-secondary"
  location            = var.az_location
  resource_group_name = local.resource_group_name

  type                       = "IPsec"
  connection_protocol        = var.azure_ipsec_version
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.cato_pop_secondary.id

  # --- CONDITIONAL BGP ---
  enable_bgp = var.azure_enable_bgp
  # --- END CONDITIONAL BGP ---

  ipsec_policy {
    # IKE Phase 1 Parameters
    ike_encryption = var.azure_secondary_connection_ike_encryption
    ike_integrity  = var.azure_secondary_connection_ike_integrity
    dh_group       = var.azure_secondary_connection_dh_group

    # IPsec Phase 2 Parameters
    ipsec_encryption = var.azure_secondary_connection_ipsec_encryption
    ipsec_integrity  = var.azure_secondary_connection_ipsec_integrity
    pfs_group        = var.azure_secondary_connection_pfs_group

    # Security Association (SA) Lifetimes
    sa_lifetime = var.azure_secondary_connection_sa_lifetime
  }

  shared_key = var.secondary_connection_shared_key == null ? random_password.shared_key_secondary.result : var.secondary_connection_shared_key
  tags       = var.tags
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
      public_cato_ip_id = data.cato_allocatedIp.primary.items[0].id
      pop_location_id   = var.primary_pop_location_id
      tunnels = [
        {
          public_site_ip  = azurerm_public_ip.vpn_gateway_primary.ip_address
          private_cato_ip = var.azure_enable_bgp ? var.primary_private_cato_ip : null
          private_site_ip = var.azure_enable_bgp ? var.azure_bgp_peering_address_0 : null

          psk = var.primary_connection_shared_key == null ? random_password.shared_key_primary.result : var.primary_connection_shared_key
          last_mile_bw = {
            downstream = var.downstream_bw
            upstream   = var.upstream_bw
          }
        }
      ]
    }
    secondary = {
      destination_type  = var.secondary_destination_type
      public_cato_ip_id = data.cato_allocatedIp.secondary.items[0].id
      pop_location_id   = var.secondary_pop_location_id
      tunnels = [
        {
          public_site_ip  = azurerm_public_ip.vpn_gateway_secondary[0].ip_address
          private_cato_ip = var.azure_enable_bgp ? var.secondary_private_cato_ip : null
          private_site_ip = var.azure_enable_bgp ? var.azure_bgp_peering_address_1 : null
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

# Since Azure doesn't support our Default DHGROUP, we have to change it to 14 
# Also Since we've hard set azure, we want to make sure that these match
# Both Init, and Auth
resource "null_resource" "update_ipsec_site_details-bgp" {
  depends_on = [cato_ipsec_site.ipsec-site]
  count      = var.azure_enable_bgp ? 1 : 0

  lifecycle {
    ignore_changes = all
  }
  triggers = {
    site_id = cato_ipsec_site.ipsec-site.id
  }

 provisioner "local-exec" {
    # This command uses a 'heredoc' to pipe the rendered JSON template
    # directly into curl's standard input.
    # The '--data @-' argument tells curl to read the POST data from stdin.
    command = <<EOT
cat <<'PAYLOAD' | curl -v -k -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'x-API-Key: ${var.token}' '${var.baseurl}' --data @-
${templatefile("${path.module}/templates/update_site_payload.json.tftpl", {
      account_id      = var.account_id
      site_id         = cato_ipsec_site.ipsec-site.id
      connection_mode = var.cato_connectionMode
      init_dh_group   = var.cato_initMessage_dhGroup
      init_cipher     = var.cato_initMessage_cipher
      init_integrity  = var.cato_initMessage_integrity
      init_prf        = var.cato_initMessage_prf
      auth_dh_group   = var.cato_authMessage_dhGroup
      auth_cipher     = var.cato_authMessage_cipher
      auth_integrity  = var.cato_authMessage_integrity
    })}
PAYLOAD
EOT
  }
}

resource "null_resource" "update_ipsec_site_details-nobgp" {
  depends_on = [cato_ipsec_site.ipsec-site]
  count      = var.azure_enable_bgp ? 0 : 1

  lifecycle {
    ignore_changes = all
  }
  triggers = {
    site_id = cato_ipsec_site.ipsec-site.id
  }

  provisioner "local-exec" {
    # Using the same robust, single-quoted heredoc pattern as before
    command = <<EOT
cat <<'PAYLOAD' | curl -v -k -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'x-API-Key: ${var.token}' '${var.baseurl}' --data @-
${templatefile("${path.module}/templates/update_site_payload_nobgp.json.tftpl", {
      account_id           = var.account_id
      site_id              = cato_ipsec_site.ipsec-site.id
      connection_mode      = var.cato_connectionMode
      # Here is the magic: jsonencode converts the Terraform list to a JSON array string
      network_ranges_json  = jsonencode(var.azure_local_networks)
      init_dh_group        = var.cato_initMessage_dhGroup
      init_cipher          = var.cato_initMessage_cipher
      init_integrity       = var.cato_initMessage_integrity
      init_prf             = var.cato_initMessage_prf
      auth_dh_group        = var.cato_authMessage_dhGroup
      auth_cipher          = var.cato_authMessage_cipher
      auth_integrity       = var.cato_authMessage_integrity
    })}
PAYLOAD
EOT
  }
}



resource "cato_bgp_peer" "primary" {
  count                    = var.azure_enable_bgp ? 1 : 0
  site_id                  = cato_ipsec_site.ipsec-site.id
  name                     = var.cato_primary_bgp_peer_name == null ? "${var.site_name}-primary-bgp-peer" : var.cato_primary_bgp_peer_name
  cato_asn                 = var.cato_bgp_asn
  peer_asn                 = var.azure_bgp_asn
  peer_ip                  = var.primary_private_site_ip
  metric                   = var.cato_primary_bgp_metric
  default_action           = var.cato_primary_bgp_default_action
  advertise_all_routes     = var.cato_primary_bgp_advertise_all
  advertise_default_route  = var.cato_primary_bgp_advertise_default_route
  advertise_summary_routes = var.cato_primary_bgp_advertise_summary_route
  md5_auth_key             = "" #Inserting Blank Value to Avoid State Changes 

  bfd_settings = {
    transmit_interval = var.cato_primary_bgp_bfd_transmit_interval
    receive_interval  = var.cato_primary_bgp_bfd_receive_interval
    multiplier        = var.cato_primary_bgp_bfd_multiplier
  }
  # Inserting Ignore to avoid API and TF Fighting over a Null Value 
  lifecycle {
    ignore_changes = [
      summary_route
    ]
  }
}

resource "cato_bgp_peer" "backup" {
  count                    = var.azure_enable_bgp ? 1 : 0
  site_id                  = cato_ipsec_site.ipsec-site.id
  name                     = var.cato_secondary_bgp_peer_name == null ? "${var.site_name}-secondary-bgp-peer" : var.cato_secondary_bgp_peer_name
  cato_asn                 = var.cato_bgp_asn
  peer_asn                 = var.azure_bgp_asn
  peer_ip                  = var.secondary_private_site_ip
  metric                   = var.cato_secondary_bgp_metric
  default_action           = var.cato_secondary_bgp_default_action
  advertise_all_routes     = var.cato_secondary_bgp_advertise_all
  advertise_default_route  = var.cato_secondary_bgp_advertise_default_route
  advertise_summary_routes = var.cato_secondary_bgp_advertise_summary_route
  md5_auth_key             = "" #Inserting Blank Value to Avoid State Changes 

  bfd_settings = {
    transmit_interval = var.cato_secondary_bgp_bfd_transmit_interval
    receive_interval  = var.cato_secondary_bgp_bfd_receive_interval
    multiplier        = var.cato_secondary_bgp_bfd_multiplier
  }

  lifecycle {
    ignore_changes = [
      summary_route
    ]
  }
}

# resource "cato_license" "license" {
#   depends_on = [cato_ipsec_site.ipsec-site]
#   count      = var.license_id == null ? 0 : 1
#   site_id    = cato_ipsec_site.ipsec-site.id
#   license_id = var.license_id
#   bw         = var.license_bw == null ? null : var.license_bw
# }
