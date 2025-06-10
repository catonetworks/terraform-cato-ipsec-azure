##The following attributes are exported:
output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.vpn_gateway.id
}

# Output for the Azure Resource Group Name
output "azure_resource_group_name" {
  description = "The name of the Azure Resource Group created."
  value       = local.resource_group_name
}

# Output for the Azure Virtual Network Name
output "azure_virtual_network_name" {
  description = "The name of the Azure Virtual Network."
  value       = local.vnet_name
}

# Output for the Primary Public IP of the Azure VPN Gateway
output "vpn_gateway_primary_public_ip" {
  description = "The primary public IP address of the Azure VPN Gateway."
  value       = azurerm_public_ip.vpn_gateway_primary.ip_address
}

# Output for the Secondary Public IP of the Azure VPN Gateway
output "vpn_gateway_secondary_public_ip" {
  description = "The secondary public IP address of the Azure VPN Gateway (for active-active configurations)."
  value       = try(azurerm_public_ip.vpn_gateway_secondary[0].ip_address, null)
}

# Output for the Primary VPN Connection Shared Key
output "primary_connection_shared_key" {
  description = "The shared key for the primary VPN connection. This is sensitive."
  value       = random_password.shared_key_primary.result
  sensitive   = true
}

# Output for the Secondary VPN Connection Shared Key
output "secondary_connection_shared_key" {
  description = "The shared key for the secondary VPN connection. This is sensitive."
  value       = random_password.shared_key_secondary.result
  sensitive   = true
}

# Output for the Cato Site ID
output "cato_site_id" {
  description = "The ID of the created Cato IPsec site."
  value       = cato_ipsec_site.ipsec-site.id
}

# Output for the Primary Local Network Gateway Details
output "primary_local_network_gateway_name" {
  description = "Name of the primary local network gateway representing the Cato PoP."
  value       = azurerm_local_network_gateway.cato_pop_primary.name
}

# Output for the Secondary Local Network Gateway Details
output "secondary_local_network_gateway_name" {
  description = "Name of the secondary local network gateway representing the Cato PoP."
  value       = azurerm_local_network_gateway.cato_pop_secondary.name
}

output "cato_license_site" {
  value = var.license_id == null ? null : {
    id           = cato_license.license[0].id
    license_id   = cato_license.license[0].license_id
    license_info = cato_license.license[0].license_info
    site_id      = cato_license.license[0].site_id
  }
}