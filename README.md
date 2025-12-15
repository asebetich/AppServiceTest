# Infrastructure
Terraform configuration for deploying a secure, highly available web application on Azure.

## Architecture Overview
Please view the Architecture diagram.pdf file

## Requirements Met

| Requirement | Implementation |
|-------------|----------------|
| **Public web application** | Application Gateway with Public IP + WAF |
| **Treat data as critical PII** | Private Endpoints, NSGs, Key Vault, Managed Identity (no secrets in code) |
| **Highly available** | Zone-redundant App Service (P1v3), Business Critical SQL |
| **Hosted in Azure** | All resources Azure-native |
| **Provisioned with Terraform** | This repository |

## Resources Created

### Networking
- 2 Virtual Networks (Frontend + Backend)
- 4 Subnets (Gateway, App, Backend, MGMT)
- Bidirectional VNet Peering
- Network Security Groups
- Private DNS Zones (SQL + Key Vault)
- Private DNS Zone Links (4 total)

### Compute
- App Service Plan (Linux, P1v3, Zone Redundant)
- Linux Web App (Python 3.11)
- App Service VNet Integration

### Data
- Azure SQL Server (public access disabled)
- Azure SQL Database (Business Critical, BC_Gen5_2)
- Private Endpoint for SQL

### Security
- Application Gateway with WAF v2 (OWASP 3.2, Prevention Mode)
- Key Vault (Standard SKU)
- Private Endpoint for Key Vault
- System-Assigned Managed Identity on App Service

## Prerequisites
- Azure subscription
- Terraform >= 1.3
- Azure CLI (`az login`)

## Required variables:
- `subscription_id`
- `tenant_id`
- `sql_admin_username`
- `sql_admin_password` (value would be pulled from GitHub/Azure DevOps Secret manager or other PW management tool)

## File Structure

```
infra/
├── main.tf              # Core resources (RG, SQL, App Service, Key Vault)
├── networking.tf        # VNets, Peering, DNS, Private Endpoints, App Gateway
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output values
├── providers.tf         # Provider configuration
├── versions.tf          # Terraform and provider versions
├── terraform.tfvars     # Variable values (do not commit secrets)
└── modules/
    ├── networking/      # VNet and subnet module
    └── keyVault/        # Key Vault module
```

## Security Features

### Network Isolation
- SQL and Key Vault accessible only via Private Endpoints
- App Service integrated into VNet
- All traffic between tiers flows through private network

### Authentication
- App Service uses Managed Identity to authenticate to SQL (no passwords in code)
- Key Vault access via Managed Identity
- Azure AD admin configured on SQL Server

### Web Application Firewall
- OWASP 3.2 rule set
- Prevention mode (blocks malicious requests)
- Protects against common web exploits

### Encryption
- TDE enabled on SQL Database (default)
- HTTPS enforced via App Gateway backend settings
- Key Vault for secret storage

## Outputs

## Outputs

### Core Resources
| Output | Description |
|--------|-------------|
| `resource_group_name` | Name of the resource group |
| `resource_group_location` | Location of the resource group |

### Networking
| Output | Description |
|--------|-------------|
| `frontend_vnet_id` | ID of the Frontend VNet |
| `frontend_vnet_name` | Name of the Frontend VNet |
| `frontend_subnet_ids` | Map of Frontend subnet names to IDs |
| `backend_vnet_id` | ID of the Backend VNet |
| `backend_vnet_name` | Name of the Backend VNet |
| `backend_subnet_ids` | Map of Backend subnet names to IDs |
| `nsg_ids` | Map of NSG names to IDs |

### Application Gateway
| Output | Description |
|--------|-------------|
| `app_gateway_id` | ID of the Application Gateway |
| `app_gateway_public_ip` | Public IP to access the application |

### App Service
| Output | Description |
|--------|-------------|
| `app_service_id` | ID of the App Service |
| `app_service_hostname` | Default hostname of the App Service |
| `app_service_principal_id` | Principal ID of the Managed Identity |
| `app_service_plan_id` | ID of the App Service Plan |

### SQL Server & Database
| Output | Description |
|--------|-------------|
| `sql_server_id` | ID of the SQL Server |
| `sql_server_fqdn` | Fully qualified domain name of the SQL Server |
| `sql_database_id` | ID of the SQL Database |
| `sql_database_name` | Name of the SQL Database |

### Key Vault
| Output | Description |
|--------|-------------|
| `key_vault_id` | ID of the Key Vault |
| `key_vault_name` | Name of the Key Vault |
| `key_vault_uri` | URI of the Key Vault |

### Private Endpoints
| Output | Description |
|--------|-------------|
| `sql_private_endpoint_ip` | Private IP of the SQL Private Endpoint |
| `keyvault_private_endpoint_ip` | Private IP of the Key Vault Private Endpoint |