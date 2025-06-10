# Resource Group (optional - create if doesn't exist)
resource "azurerm_resource_group" "vnet_rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.common_tags
}

# Virtual Network with enhanced configuration
resource "azurerm_virtual_network" "my-vnet" {
  name                = var.azurerm_virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  flow_timeout_in_minutes = var.flow_timeout_in_minutes  
  depends_on = [azurerm_resource_group.vnet_rg]
}

# Virtual Network Peering

resource "azurerm_virtual_network_peering" "vnet_peering" {
  for_each = var.create_vnet_peering ? var.vnet_peering_details : {}
  name                      = each.value.name
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.my-vnet.name
  remote_virtual_network_id = each.value.remote_virtual_network_id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  depends_on = [azurerm_resource_group.vnet_rg]
}

# Network Security Groups - Created per subnet when enabled
resource "azurerm_network_security_group" "subnet_nsg" {
  for_each = {
    for key, subnet in var.subnet_details : key => subnet
    if subnet.nsg == "enable"
  }
  
  name                = "${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  depends_on = [azurerm_resource_group.vnet_rg]
}

# NSG Rules - Applied per subnet based on subnet configuration
resource "azurerm_network_security_rule" "subnet_nsg_rules" {
  for_each = {
    for item in flatten([
      for subnet_key, subnet in var.subnet_details : [
        for rule in subnet.nsg_rules : {
          subnet_key = subnet_key
          rule_key   = "${subnet_key}-${rule.name}"
          rule       = rule
        }
      ] if subnet.nsg == "enable"
    ]) : item.rule_key => item
  }

  name                        = each.value.rule.name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  source_port_range           = each.value.rule.source_port_range
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = each.value.rule.source_address_prefix
  destination_address_prefix  = each.value.rule.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnet_nsg[each.value.subnet_key].name
}

# Route Tables - Created per subnet when enabled with custom routes
resource "azurerm_route_table" "subnet_rt" {
  for_each = {
    for key, subnet in var.subnet_details : key => subnet
    if subnet.route_table == "enable"
  }
  
  name                = "${each.key}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  # Dynamic routes based on subnet configuration
  dynamic "route" {
    for_each = each.value.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }

  depends_on = [azurerm_resource_group.vnet_rg]
}

# Enhanced Subnets with advanced features
resource "azurerm_subnet" "my-subnet" {
  for_each             = var.subnet_details
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.my-vnet.name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = length(each.value.service_endpoints) > 0 ? each.value.service_endpoints : null
}

# NSG Association - Only for subnets with NSG enabled
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  for_each = {
    for key, subnet in var.subnet_details : key => subnet
    if subnet.nsg == "enable"
  }
  
  subnet_id                 = azurerm_subnet.my-subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.subnet_nsg[each.key].id
}

# Route Table Association - Only for subnets with route table enabled
resource "azurerm_subnet_route_table_association" "subnet_rt_association" {
  for_each = {
    for key, subnet in var.subnet_details : key => subnet
    if subnet.route_table == "enable"
  }
  
  subnet_id      = azurerm_subnet.my-subnet[each.key].id
  route_table_id = azurerm_route_table.subnet_rt[each.key].id
}

# Public IP for Bastion
resource "azurerm_public_ip" "my-public-ip" {
  count               = var.create_bastion ? 1 : 0
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.allocation_method
  sku                 = var.public_ip_sku
  tags                = var.common_tags

  depends_on = [azurerm_resource_group.vnet_rg]
}

# Azure Bastion Host
resource "azurerm_bastion_host" "my-bastion" {
  count               = var.create_bastion ? 1 : 0
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
  sku                 = var.bastion_sku
  scale_units         = var.bastion_scale_units

  ip_configuration {
    name                 = var.ip_configuration_name
    subnet_id            = azurerm_subnet.my-subnet["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.my-public-ip[0].id
  }

  copy_paste_enabled = var.bastion_copy_paste_enabled
  file_copy_enabled = var.bastion_sku == "Standard" ? var.bastion_file_copy_enabled : false
  ip_connect_enabled = var.bastion_sku == "Standard" ? var.bastion_ip_connect_enabled : false
  shareable_link_enabled = var.bastion_sku == "Standard" ? var.bastion_shareable_link_enabled : false
  tunneling_enabled = var.bastion_sku == "Standard" ? var.bastion_tunneling_enabled : false
  depends_on = [azurerm_resource_group.vnet_rg]
}