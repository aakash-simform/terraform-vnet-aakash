variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    environment = "Terraform Module Demo"
    owner       = "Aakash"
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "subnet_details" {
  description = "Map of subnet configurations with advanced options"
  type = map(object({
    name              = string
    address_prefix    = string
    service_endpoints = optional(list(string), [])
    route_table_id    = optional(string, null)
    nsg_id           = optional(string, null)
    nsg              = optional(string, "disable")  # "enable" or "disable"
    nsg_rules        = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
    route_table      = optional(string, "disable")  # "enable" or "disable"
    routes           = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string, null)
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for subnet in var.subnet_details : contains(["enable", "disable"], subnet.nsg)
    ])
    error_message = "NSG setting must be either 'enable' or 'disable' for each subnet."
  }

  validation {
    condition = alltrue([
      for subnet in var.subnet_details : contains(["enable", "disable"], subnet.route_table)
    ])
    error_message = "Route table setting must be either 'enable' or 'disable' for each subnet."
  }

  validation {
    condition = alltrue([
      for subnet in var.subnet_details : 
        subnet.route_table == "disable" || length(subnet.routes) > 0
    ])
    error_message = "When route_table is enabled, at least one route must be defined."
  }
}

variable "address_space" {
  description = "Address space for the Azure Virtual Network"
  type        = list(string)
}


variable "azurerm_virtual_network_name" {
  description = "Name of the Azure Virtual Network"
  type        = string
}

variable "vnet_encryption_enforcement" {
  description = "Enforcement of encryption for the virtual network"
  type        = string
}
variable "public_ip_name" {
  description = "Name of the Public IP for Azure Bastion"
  type        = string
}

variable "allocation_method" {
  description = "Allocation method for the Public IP (Static or Dynamic)"
  type        = string
}

variable "public_ip_sku" {
  description = "SKU for the Public IP (Standard or Basic)"
  type        = string
}

variable "bastion_name" {
  description = "Name of the Azure Bastion Host"
  type        = string
  default     = null
}

variable "create_bastion" {
  description = "Flag to create Azure Bastion Host"
  type        = bool
  default     = false
}

variable "ip_configuration_name" {
  description = "Name of the IP configuration for Azure Bastion"
  type        = string
  default     = null
}

variable "create_resource_group" {
  description = "Flag to create a new resource group"
  type        = bool
  default     = false
}

variable "disable_bgp_route_propagation" {
  description = "Boolean flag which controls propagation of routes learned by BGP on route table"
  type        = bool
  default     = false
}

variable "bastion_sku" {
  description = "SKU for Azure Bastion (Basic or Standard)"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard"], var.bastion_sku)
    error_message = "Bastion SKU must be either 'Basic' or 'Standard'."
  }
}

variable "bastion_scale_units" {
  description = "Number of scale units for Azure Bastion (2-50, only for Standard SKU)"
  type        = number
  default     = 2
  validation {
    condition     = var.bastion_scale_units >= 2 && var.bastion_scale_units <= 50
    error_message = "Bastion scale units must be between 2 and 50."
  }
}

variable "bastion_copy_paste_enabled" {
  description = "Enable copy/paste functionality for Azure Bastion"
  type        = bool
  default     = true
}

variable "bastion_file_copy_enabled" {
  description = "Enable file copy functionality for Azure Bastion (Standard SKU only)"
  type        = bool
  default     = false
}

variable "bastion_ip_connect_enabled" {
  description = "Enable IP connect functionality for Azure Bastion (Standard SKU only)"
  type        = bool
  default     = false
}

variable "bastion_shareable_link_enabled" {
  description = "Enable shareable link functionality for Azure Bastion (Standard SKU only)"
  type        = bool
  default     = false
}

variable "bastion_tunneling_enabled" {
  description = "Enable tunneling functionality for Azure Bastion (Standard SKU only)"
  type        = bool
  default     = false
}

variable "dns_servers" {
  description = "List of DNS servers for the VNet"
  type        = list(string)
  default     = []
}

variable "flow_timeout_in_minutes" {
  description = "Flow timeout in minutes for the VNet"
  type        = number
  default     = 4
  validation {
    condition     = var.flow_timeout_in_minutes >= 4 && var.flow_timeout_in_minutes <= 30
    error_message = "Flow timeout must be between 4 and 30 minutes."
  }
}

variable "create_vnet_peering" {
  description = "Flag to create VNet peering"
  type        = bool
  default     = false  
}

variable "vnet_peering_details" {
  description = "Map of VNet peering configurations"
  type = map(object({
    name                     = string
    remote_virtual_network_id = string
    allow_virtual_network_access = optional(bool, true)    
  }))
  default = null
}