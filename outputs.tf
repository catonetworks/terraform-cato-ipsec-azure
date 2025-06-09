# ##The following attributes are exported:
# output "vpn_gateway_id" {
#   description = "The ID of the VPN Gateway"
#   value       = azurerm_virtual_network_gateway.vpn_gateway.id
# }

# output "vpn_gateway_public_ip" {
#   description = "The public IP address of the VPN Gateway"
#   value       = azurerm_public_ip.vpn_gateway_pip.ip_address
# }

# output "site_id" {
#   description = "ID of the created Cato IPSec site"
#   value       = cato_ipsec_site.ipsec-site.id
# }

# output "cato_license_site" {
#   value = var.license_id == null ? null : {
#     id           = cato_license.license[0].id
#     license_id   = cato_license.license[0].license_id
#     license_info = cato_license.license[0].license_info
#     site_id      = cato_license.license[0].site_id
#   }
# }