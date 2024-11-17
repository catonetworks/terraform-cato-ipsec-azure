##The following attributes are exported:
output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.vpn_gateway.id
}

output "site_id" {
  description = "ID of the created Cato IPSec site"
  value       = cato_ipsec_site.ipsec-site.id
}