output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.my-vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.my-vnet.name
}

output "vnet_resource_group_name" {
  description = "The resource group name of the Virtual Network"
  value       = azurerm_virtual_network.my-vnet.resource_group_name
}

output "vnet_location" {
  description = "The location of the Virtual Network"
  value       = azurerm_virtual_network.my-vnet.location
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = azurerm_virtual_network.my-vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    for k, v in azurerm_subnet.my-subnet : k => v.id
  }
}

output "subnet_names" {
  description = "List of subnet names"
  value       = [for s in azurerm_subnet.my-subnet : s.name]
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value = {
    for k, v in azurerm_subnet.my-subnet : k => v.address_prefixes
  }
}

output "nsg_ids" {
  description = "Map of subnet names to their NSG IDs"
  value = {
    for k, v in azurerm_network_security_group.subnet_nsg : k => v.id
  }
}

output "nsg_names" {
  description = "Map of subnet names to their NSG names"
  value = {
    for k, v in azurerm_network_security_group.subnet_nsg : k => v.name
  }
}

output "route_table_ids" {
  description = "Map of subnet names to their route table IDs"
  value = {
    for k, v in azurerm_route_table.subnet_rt : k => v.id
  }
}

output "route_table_names" {
  description = "Map of subnet names to their route table names"
  value = {
    for k, v in azurerm_route_table.subnet_rt : k => v.name
  }
}

output "public_ip_id" {
  description = "The ID of the Public IP (if created)"
  value       = var.create_bastion ? azurerm_public_ip.my-public-ip[0].id : null
}

output "public_ip_address" {
  description = "The IP address of the Public IP (if created)"
  value       = var.create_bastion ? azurerm_public_ip.my-public-ip[0].ip_address : null
}

output "bastion_id" {
  description = "The ID of the Azure Bastion Host (if created)"
  value       = var.create_bastion ? azurerm_bastion_host.my-bastion[0].id : null
}

output "bastion_name" {
  description = "The name of the Azure Bastion Host (if created)"
  value       = var.create_bastion ? azurerm_bastion_host.my-bastion[0].name : null
}

output "bastion_fqdn" {
  description = "The FQDN of the Azure Bastion Host (if created)"
  value       = var.create_bastion ? azurerm_bastion_host.my-bastion[0].dns_name : null
}

output "resource_group_id" {
  description = "The ID of the resource group (if created by module)"
  value       = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].id : null
}

output "vnet_peering_ids" {
  description = "Map of VNet peering names to their IDs"
  value = {
    for k, v in azurerm_virtual_network_peering.vnet_peering : k => v.id
  }  
}

# Summary outputs for convenience
output "network_summary" {
  description = "Summary of the network configuration"
  value = {
    vnet_name     = azurerm_virtual_network.my-vnet.name
    vnet_id       = azurerm_virtual_network.my-vnet.id
    address_space = azurerm_virtual_network.my-vnet.address_space
    subnet_count  = length(azurerm_subnet.my-subnet)
    vnet_peering_details = {
      for k, v in azurerm_virtual_network_peering.vnet_peering : k => {
        id                = v.id
        name              = v.name
        remote_vnet_id    = v.remote_virtual_network_id
        allow_virtual_network_access = v.allow_virtual_network_access
      }
    }
    subnets = {
      for k, v in azurerm_subnet.my-subnet : k => {
        id                     = v.id
        address_prefixes       = v.address_prefixes
        service_endpoints      = v.service_endpoints
        nsg_enabled           = lookup(var.subnet_details[k], "nsg", "disable") == "enable"
        nsg_id                = lookup(var.subnet_details[k], "nsg", "disable") == "enable" ? azurerm_network_security_group.subnet_nsg[k].id : null
        route_table_enabled   = lookup(var.subnet_details[k], "route_table", "disable") == "enable"
        route_table_id        = lookup(var.subnet_details[k], "route_table", "disable") == "enable" ? azurerm_route_table.subnet_rt[k].id : null
      }
    }
    bastion_enabled          = var.create_bastion
    nsg_enabled_subnets      = [for k, v in var.subnet_details : k if v.nsg == "enable"]
    route_table_enabled_subnets = [for k, v in var.subnet_details : k if v.route_table == "enable"]
  }
}