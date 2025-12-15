#Provider Configuration
subscription_id = "#####-#####-####-####-############"
tenant_id       = "#####-#####-####-####-############"

#General Variables
tags = {
  Environment = "Dev"
  Project     = "AppServiceTest"
  Owner       = "Adam"
}
location = "West US"

#Resource group
rg_name = "rg01"

#Networking Module Frontend VNET
frontend_vnet_name          = "Frontend-VNET"
frontend_vnet_address_space = "10.0.0.0/16"
frontend_subnets = {
  gatewaySubnet = {
    subnet_name      = "Gateway-Subnet"
    address_prefixes = ["10.0.0.0/24"]
  },
  frontend_subnet = {
    subnet_name      = "Frontend-Subnet"
    address_prefixes = ["10.0.1.0/24"]
    delegation = [
      {
        name = "delegationAppService"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/write", "Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    ]
  }
}

#Networking Module Backend VNET
backend_vnet_name          = "Backend-VNET"
backend_vnet_address_space = "10.1.0.0/16"
backend_subnets = {
  backend_subnet = {
    subnet_name                               = "Backend-Subnet"
    address_prefixes                          = ["10.1.0.0/24"]
    private_endpoint_network_policies_enabled = true
  },
  mgmt_subnet = {
    subnet_name                               = "MGMT-Subnet"
    address_prefixes                          = ["10.1.1.0/24"]
    private_endpoint_network_policies_enabled = true
  }
}

#App Service Variables
asp_name          = "AppServicePlan01"
linux_app_name    = "LinuxApp01"

# SQL Database Server Variables
sql_server_name    = "sqlserver01"
sql_admin_username = "sqladminuser"
sql_admin_password = "#{SQL_ADMIN_PASSWORD}#"

sql_database_name = "Database01"

#Network Security Group
network_security_groups = {
  appgw-nsg = {
    rules = {
      Allow-HTTP = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }
      Allow-HTTPS = {
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }
      Allow-GatewayManager = {
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      }
    }
  },
frontend-nsg = {
    rules = {
      Allow-From-AppGW = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.0.0.0/24"
        destination_address_prefix = "*"
      }
      Deny-All-Inbound = {
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  },
  backend-nsg = {
    rules = {
      Allow-SQL-From-Frontend = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "10.0.1.0/24"
        destination_address_prefix = "*"
      }
      Deny-All-Inbound = {
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  },
  mgmt-nsg = {
    rules = {
      Allow-KV-From-Frontend = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "10.0.1.0/24"
        destination_address_prefix = "*"
      }
      Deny-All-Inbound = {
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
  }
}
nsg_subnet_associations = {
  appgw-association = {
    subnet_key  = "gatewaySubnet"
    nsg_key     = "appgw-nsg"
    vnet_module = "frontend"
  },
  frontend-association = {
    subnet_key  = "frontend_subnet"
    nsg_key     = "frontend-nsg"
    vnet_module = "frontend"
  },
  backend-association = {
    subnet_key  = "backend_subnet"
    nsg_key     = "backend-nsg"
    vnet_module = "backend"
  },
  mgmt-association = {
    subnet_key  = "mgmt_subnet"
    nsg_key     = "mgmt-nsg"
    vnet_module = "backend"
  }
}