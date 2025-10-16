# SQL Azure VM Deployment with SQL IaaS Agent Extension

## Overview

This Terraform configuration deploys a complete SQL Server Virtual Machine infrastructure on Azure with automatic registration to the SQL IaaS Agent Extension.

## Key Components

### 1. Virtual Machine Infrastructure
- **Windows Virtual Machine**: Deploys a Windows VM with SQL Server pre-installed from Azure Marketplace
- **Networking**: Complete network setup including VNet, Subnet, Public IP, and Network Interface
- **Security**: Network Security Group with rules for RDP (3389) and SQL Server (1433) access

### 2. SQL IaaS Agent Extension
The `azurerm_mssql_virtual_machine` resource automatically registers the SQL VM with the SQL IaaS Agent Extension, providing:

- **Automated Patching**: Configure maintenance windows and automatic SQL Server updates
- **Automated Backup**: Backup to Azure Storage with encryption
- **License Management**: Track and manage SQL Server licenses (PAYG, AHUB, or DR)
- **SQL Connectivity**: Configure SQL Server network settings
- **Monitoring**: Integration with Azure Monitor and Security Center

### 3. Storage Account
- Dedicated storage account for SQL Server automated backups
- Configured with LRS replication
- Uses random suffix for global uniqueness

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Resource Group                        │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │              Virtual Network                     │   │
│  │  ┌────────────────────────────────────────────┐  │   │
│  │  │            Subnet                          │  │   │
│  │  │  ┌──────────────────────────────────────┐  │  │   │
│  │  │  │      Network Interface              │  │  │   │
│  │  │  │  - Public IP                        │  │  │   │
│  │  │  │  - Private IP                       │  │  │   │
│  │  │  │  - NSG (RDP + SQL)                  │  │  │   │
│  │  │  └──────────────┬───────────────────────┘  │  │   │
│  │  └─────────────────┼──────────────────────────┘  │   │
│  └────────────────────┼─────────────────────────────┘   │
│                       │                                  │
│  ┌────────────────────▼─────────────────────────────┐   │
│  │    Windows VM with SQL Server                    │   │
│  │    - SQL Server 2019 Standard                    │   │
│  │    - Premium SSD                                 │   │
│  │    - Auto-patching enabled                       │   │
│  │    - Auto-backup enabled                         │   │
│  └────────────────────┬─────────────────────────────┘   │
│                       │                                  │
│  ┌────────────────────▼─────────────────────────────┐   │
│  │    SQL IaaS Agent Extension                      │   │
│  │    - Automatic registration                      │   │
│  │    - Management features                         │   │
│  │    - License tracking                            │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │    Storage Account                               │   │
│  │    - SQL Server backups                          │   │
│  │    - 30-day retention                            │   │
│  │    - Encrypted                                   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## How It Works

### SQL IaaS Agent Extension Registration

The `azurerm_mssql_virtual_machine` resource in Terraform automatically:

1. Detects the SQL Server installation on the VM
2. Registers the VM with the SQL IaaS Agent Extension
3. Configures all management features (patching, backup, monitoring)
4. Enables centralized management through Azure portal

This happens automatically during the Terraform deployment - no manual intervention required.

### Configuration Options

#### SQL License Types
- **PAYG** (Pay-As-You-Go): Pay per second for SQL Server license
- **AHUB** (Azure Hybrid Benefit): Use existing on-premises licenses
- **DR** (Disaster Recovery): Free replica for disaster recovery

#### SQL Server Versions
- SQL Server 2019 (default)
- SQL Server 2017
- SQL Server 2016 SP3

#### SQL Server Editions
- Enterprise
- Standard (default)
- Web

## Deployment Steps

1. **Prerequisites**
   - Azure subscription
   - Terraform installed (>= 1.0)
   - Azure CLI authenticated or service principal credentials

2. **Configuration**
   ```bash
   # Copy example variables
   cp terraform.tfvars.example terraform.tfvars
   
   # Edit terraform.tfvars and set admin_password
   vim terraform.tfvars
   ```

3. **Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Verify**
   - Check Azure Portal for the SQL Virtual Machine resource
   - Verify SQL IaaS Agent Extension is registered
   - Review automated backup and patching configuration

## Security Best Practices

1. **Network Security**
   - Restrict NSG rules to specific IP ranges
   - Use Azure Bastion for RDP access
   - Consider private endpoints for SQL connectivity

2. **Secrets Management**
   - Store passwords in Azure Key Vault
   - Use managed identities where possible
   - Rotate credentials regularly

3. **Backup and Recovery**
   - Test backup restoration regularly
   - Configure geo-redundant storage for backups
   - Document recovery procedures

4. **Monitoring**
   - Enable Azure Monitor for SQL VM
   - Configure alerts for critical events
   - Review logs regularly

## Cost Optimization

- Choose appropriate VM size based on workload
- Use Azure Hybrid Benefit if you have existing licenses
- Configure auto-shutdown for development environments
- Use reserved instances for production workloads

## Troubleshooting

### Common Issues

1. **Extension Registration Fails**
   - Ensure VM has internet connectivity
   - Check that SQL Server is properly installed
   - Verify Azure RBAC permissions

2. **Backup Configuration Issues**
   - Verify storage account access
   - Check encryption password complexity
   - Ensure sufficient storage space

3. **Connectivity Issues**
   - Verify NSG rules
   - Check SQL Server network configuration
   - Confirm firewall settings

## References

- [Azure SQL Virtual Machines Documentation](https://docs.microsoft.com/azure/azure-sql/virtual-machines/)
- [SQL IaaS Agent Extension](https://docs.microsoft.com/azure/azure-sql/virtual-machines/windows/sql-server-iaas-agent-extension-automate-management)
- [Terraform azurerm_mssql_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine)
