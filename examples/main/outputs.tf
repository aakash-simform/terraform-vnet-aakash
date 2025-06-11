# VNet Module Outputs
output "vnet_summary" {
  description = "Complete summary of the VNet module deployment"
  value       = module.custom_vnet.network_summary
}

output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.custom_vnet.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.custom_vnet.subnet_ids
}

output "nsg_ids" {
  description = "Map of NSG IDs by subnet"
  value       = module.custom_vnet.nsg_ids
}

output "route_table_ids" {
  description = "Map of Route Table IDs by subnet"
  value       = module.custom_vnet.route_table_ids
}

output "bastion_id" {
  description = "Azure Bastion Host ID (if created)"
  value       = module.custom_vnet.bastion_id
}

output "public_ip_address" {
  description = "Public IP address (if created)"
  value       = module.custom_vnet.public_ip_address
}
