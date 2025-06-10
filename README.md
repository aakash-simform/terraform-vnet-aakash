# Azure Virtual Network (VNet) Terraform Module

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)

A comprehensive Terraform module for creating Azure Virtual Networks with advanced networking features including subnets, Network Security Groups (NSGs), Route Tables, VNet peering, and Azure Bastion integration.

## 🏗️ Architecture

This module creates a complete Azure networking infrastructure with the following components:

- **Virtual Network (VNet)** with configurable address space and DNS settings
- **Subnets** with flexible configuration options
- **Network Security Groups (NSGs)** with custom security rules per subnet
- **Route Tables** with custom routes per subnet
- **VNet Peering** for connecting multiple virtual networks
- **Azure Bastion** for secure remote access
- **Public IP** for Bastion host (when enabled)
- **Resource Group** (optional creation)

## 📋 Features

- ✅ **Flexible Subnet Configuration**: Create multiple subnets with custom CIDR blocks
- ✅ **Advanced Security**: Per-subnet NSG configuration with custom rules
- ✅ **Custom Routing**: Route tables with user-defined routes
- ✅ **VNet Peering**: Connect multiple virtual networks
- ✅ **Azure Bastion Integration**: Secure RDP/SSH access without public IPs
- ✅ **Service Endpoints**: Configure Azure service endpoints per subnet
- ✅ **DNS Configuration**: Custom DNS servers support
- ✅ **Resource Tagging**: Consistent tagging across all resources
- ✅ **Validation**: Input validation for common configuration errors

## 🚀 Quick Start

### Basic Usage

```hcl
module "vnet" {
  source = "./module"

  # Basic Configuration
  location                     = "Central India"
  resource_group_name          = "my-rg"
  azurerm_virtual_network_name = "my-vnet"
  address_space                = ["10.0.0.0/16"]

  # Public IP Configuration (required even if Bastion is not created)
  public_ip_name    = "my-public-ip"
  allocation_method = "Static"
  public_ip_sku     = "Standard"

  # Subnet Configuration
  subnet_details = {
    web_subnet = {
      name           = "web-subnet"
      address_prefix = "10.0.1.0/24"
      nsg            = "enable"
      nsg_rules = [
        {
          name                       = "allow-http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  common_tags = {
    environment = "production"
    project     = "web-app"
    owner       = "devops-team"
  }
}
```

### Advanced Configuration with Bastion

```hcl
module "vnet" {
  source = "./module"

  # Basic Configuration
  location                     = "Central India"
  resource_group_name          = "my-rg"
  azurerm_virtual_network_name = "my-vnet"
  address_space                = ["10.0.0.0/16"]
  dns_servers                  = ["8.8.8.8", "8.8.4.4"]
  flow_timeout_in_minutes      = 10

  # Public IP Configuration
  public_ip_name    = "bastion-public-ip"
  allocation_method = "Static"
  public_ip_sku     = "Standard"

  # Bastion Configuration
  create_bastion                 = true
  bastion_name                   = "my-bastion"
  ip_configuration_name          = "bastion-ip-config"
  bastion_sku                    = "Standard"
  bastion_scale_units            = 2
  bastion_copy_paste_enabled     = true
  bastion_file_copy_enabled      = true
  bastion_ip_connect_enabled     = true
  bastion_tunneling_enabled      = true

  # Subnet Configuration
  subnet_details = {
    AzureBastionSubnet = {
      name           = "AzureBastionSubnet"
      address_prefix = "10.0.0.0/27"
      nsg            = "disable"
    }
    web_subnet = {
      name              = "web-subnet"
      address_prefix    = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      nsg               = "enable"
      nsg_rules = [
        {
          name                       = "allow-http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
      route_table = "enable"
      routes = [
        {
          name                   = "route-to-firewall"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.100.4"
        }
      ]
    }
  }

  # VNet Peering
  create_vnet_peering = true
  vnet_peering_details = {
    hub_peering = {
      name                         = "hub-to-spoke"
      remote_virtual_network_id    = "/subscriptions/xxx/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet"
      allow_virtual_network_access = true
    }
  }

  common_tags = {
    environment = "production"
    project     = "enterprise-app"
    owner       = "network-team"
  }
}
```

## 📊 Inputs

### Required Variables

| Name | Description | Type | Example |
|------|-------------|------|---------|
| `location` | Azure region where resources will be created | `string` | `"Central India"` |
| `resource_group_name` | Name of the Azure Resource Group | `string` | `"my-rg"` |
| `azurerm_virtual_network_name` | Name of the Azure Virtual Network | `string` | `"my-vnet"` |
| `address_space` | Address space for the Azure Virtual Network | `list(string)` | `["10.0.0.0/16"]` |
| `public_ip_name` | Name of the Public IP for Azure Bastion | `string` | `"my-public-ip"` |
| `allocation_method` | Allocation method for the Public IP | `string` | `"Static"` |
| `public_ip_sku` | SKU for the Public IP | `string` | `"Standard"` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_resource_group` | Flag to create a new resource group | `bool` | `false` |
| `dns_servers` | List of DNS servers for the VNet | `list(string)` | `[]` |
| `flow_timeout_in_minutes` | Flow timeout in minutes for the VNet (4-30) | `number` | `4` |
| `create_bastion` | Flag to create Azure Bastion Host | `bool` | `false` |
| `bastion_sku` | SKU for Azure Bastion (Basic or Standard) | `string` | `"Basic"` |
| `create_vnet_peering` | Flag to create VNet peering | `bool` | `false` |

### Complex Variables

#### `subnet_details`
Map of subnet configurations with advanced options:

```hcl
subnet_details = {
  subnet_key = {
    name              = string              # Subnet name
    address_prefix    = string              # CIDR block
    service_endpoints = list(string)        # Azure service endpoints
    nsg               = string              # "enable" or "disable"
    nsg_rules = list(object({              # NSG rules (when nsg = "enable")
      name                       = string
      priority                   = number
      direction                  = string   # "Inbound" or "Outbound"
      access                     = string   # "Allow" or "Deny"
      protocol                   = string   # "Tcp", "Udp", or "*"
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
    route_table = string                   # "enable" or "disable"
    routes = list(object({                 # Custom routes (when route_table = "enable")
      name                   = string
      address_prefix         = string
      next_hop_type          = string      # "Internet", "VirtualAppliance", etc.
      next_hop_in_ip_address = string      # Required for VirtualAppliance
    }))
  }
}
```

#### `vnet_peering_details`
Map of VNet peering configurations:

```hcl
vnet_peering_details = {
  peering_key = {
    name                         = string  # Peering name
    remote_virtual_network_id    = string  # Full resource ID of remote VNet
    allow_virtual_network_access = bool    # Allow virtual network access
  }
}
```

## 📤 Outputs

| Name | Description |
|------|-------------|
| `vnet_id` | The ID of the Virtual Network |
| `vnet_name` | The name of the Virtual Network |
| `subnet_ids` | Map of subnet names to their IDs |
| `nsg_ids` | Map of NSG IDs by subnet |
| `route_table_ids` | Map of Route Table IDs by subnet |
| `bastion_id` | Azure Bastion Host ID (if created) |
| `public_ip_address` | Public IP address (if created) |
| `network_summary` | Complete summary of the network configuration |

## 🔧 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

## 📝 Examples

### Example 1: Simple Web Application Setup

```hcl
module "web_vnet" {
  source = "./module"

  location                     = "East US"
  resource_group_name          = "web-app-rg"
  azurerm_virtual_network_name = "web-vnet"
  address_space                = ["10.1.0.0/16"]

  public_ip_name    = "web-public-ip"
  allocation_method = "Static"
  public_ip_sku     = "Standard"

  subnet_details = {
    web_tier = {
      name           = "web-tier"
      address_prefix = "10.1.1.0/24"
      nsg            = "enable"
      nsg_rules = [
        {
          name                       = "allow-http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-https"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    database_tier = {
      name           = "database-tier"
      address_prefix = "10.1.2.0/24"
      nsg            = "enable"
      nsg_rules = [
        {
          name                       = "allow-sql"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.1.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  common_tags = {
    environment = "production"
    application = "web-app"
  }
}
```

### Example 2: Enterprise Setup with Bastion and Peering

```hcl
module "enterprise_vnet" {
  source = "./module"

  location                     = "West Europe"
  resource_group_name          = "enterprise-rg"
  azurerm_virtual_network_name = "enterprise-vnet"
  address_space                = ["10.0.0.0/16"]
  dns_servers                  = ["10.0.0.4", "10.0.0.5"]

  public_ip_name    = "bastion-pip"
  allocation_method = "Static"
  public_ip_sku     = "Standard"

  create_bastion            = true
  bastion_name              = "enterprise-bastion"
  ip_configuration_name     = "bastion-config"
  bastion_sku               = "Standard"
  bastion_scale_units       = 4
  bastion_copy_paste_enabled = true
  bastion_file_copy_enabled  = true

  subnet_details = {
    AzureBastionSubnet = {
      name           = "AzureBastionSubnet"
      address_prefix = "10.0.0.0/27"
      nsg            = "disable"
    }
    dmz_subnet = {
      name              = "dmz-subnet"
      address_prefix    = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage"]
      nsg               = "enable"
      nsg_rules = [
        {
          name                       = "allow-internet-inbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
      route_table = "enable"
      routes = [
        {
          name                   = "default-route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.100.4"
        }
      ]
    }
  }

  create_vnet_peering = true
  vnet_peering_details = {
    hub_connection = {
      name                         = "enterprise-to-hub"
      remote_virtual_network_id    = "/subscriptions/xxx/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet"
      allow_virtual_network_access = true
    }
  }

  common_tags = {
    environment = "production"
    cost_center = "IT"
    compliance  = "PCI-DSS"
  }
}
```

## 🔒 Security Considerations

1. **Network Security Groups**: Configure appropriate NSG rules for each subnet
2. **Service Endpoints**: Use service endpoints to secure access to Azure services
3. **Bastion Host**: Use Azure Bastion for secure remote access instead of public IPs
4. **Route Tables**: Implement custom routing for traffic inspection
5. **VNet Peering**: Secure network connectivity between VNets

## 🏷️ Resource Naming Convention

The module follows Azure naming conventions:
- VNet: `{azurerm_virtual_network_name}`
- Subnets: `{subnet_details.name}`
- NSGs: `{subnet_key}-nsg`
- Route Tables: `{subnet_key}-rt`
- Bastion: `{bastion_name}`

## 🧪 Testing

To test this module:

1. **Plan**: Review the Terraform plan
```bash
terraform plan
```

2. **Apply**: Deploy the infrastructure
```bash
terraform apply
```

3. **Validate**: Check the created resources in Azure Portal

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This module is released under the MIT License. See [LICENSE](LICENSE) for details.

## 👨‍💻 Author

**Aakash Shah**
- GitHub: [@aakash-shah](https://github.com/aakash-shah)
- LinkedIn: [Aakash Shah](https://linkedin.com/in/aakash-shah)

## 📞 Support

For questions, issues, or contributions, please:
1. Check existing [issues](../../issues)
2. Create a new issue with detailed information
3. Follow the contribution guidelines

---

⭐ **Star this repository if you find it helpful!**