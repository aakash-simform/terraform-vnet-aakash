module "custom_vnet" {
  source  = "aakash-simform/aakash/vnet"
  common_tags                  = var.common_tags
  location                     = var.location
  resource_group_name          = var.resource_group_name
  azurerm_virtual_network_name = var.azurerm_virtual_network_name
  vnet_encryption_enforcement  = var.vnet_encryption_enforcement
  public_ip_name               = var.public_ip_name
  allocation_method            = var.allocation_method
  public_ip_sku                = var.public_ip_sku
  address_space                = var.address_space
  # subnet_details               = var.subnet_details

  # New enhanced features
  # create_resource_group   = var.create_resource_group
  # dns_servers             = var.dns_servers
  # flow_timeout_in_minutes = var.flow_timeout_in_minutes

  # create_vnet_peering  = var.create_vnet_peering
  # vnet_peering_details = var.vnet_peering_details

  # create_bastion                 = var.create_bastion
  # bastion_sku                    = var.bastion_sku
  # bastion_scale_units            = var.bastion_scale_units
  # bastion_copy_paste_enabled     = var.bastion_copy_paste_enabled
  # bastion_file_copy_enabled      = var.bastion_file_copy_enabled
  # bastion_ip_connect_enabled     = var.bastion_ip_connect_enabled
  # bastion_shareable_link_enabled = var.bastion_shareable_link_enabled
  # bastion_tunneling_enabled      = var.bastion_tunneling_enabled
}