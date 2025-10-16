# SQL Azure VM with IaaS Agent Extension - Terraform Demo

This repository contains Terraform configuration to deploy an Azure SQL Server Virtual Machine with automatic registration to the SQL IaaS Agent Extension.

## Features

- Deploys a Windows Virtual Machine with SQL Server pre-installed
- Automatically registers the VM with SQL IaaS Agent Extension
- Configures networking (VNet, Subnet, NSG, Public IP)
- Enables SQL connectivity with configurable settings
- Configures automatic patching for SQL Server
- Sets up automatic backups to Azure Storage
- Creates necessary security rules for RDP and SQL Server access

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- An Azure subscription
- Azure CLI installed and authenticated, or appropriate service principal credentials

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sharmilamusunuru/sqlextensioninstalldemo.git
   cd sqlextensioninstalldemo
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Create a terraform.tfvars file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit `terraform.tfvars` and set your values, especially the `admin_password`:
   ```hcl
   admin_password = "YourSecurePassword123!"
   ```

4. **Review the deployment plan:**
   ```bash
   terraform plan
   ```

5. **Deploy the infrastructure:**
   ```bash
   terraform apply
   ```

6. **View outputs:**
   ```bash
   terraform output
   ```

## Configuration Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `resource_group_name` | Name of the resource group | `sql-vm-rg` | No |
| `location` | Azure region for resources | `East US` | No |
| `prefix` | Prefix for resource names | `sqlvm` | No |
| `vm_size` | Size of the virtual machine | `Standard_D2s_v3` | No |
| `admin_username` | Administrator username | `sqladmin` | No |
| `admin_password` | Administrator password | - | **Yes** |
| `sql_server_offer` | SQL Server offer | `sql2019-ws2019` | No |
| `sql_server_sku` | SQL Server SKU | `standard-gen2` | No |
| `sql_license_type` | License type (PAYG/AHUB/DR) | `PAYG` | No |
| `auto_patching_day_of_week` | Day for auto patching | `Sunday` | No |

## Outputs

After successful deployment, the following information will be available:

- Resource group name
- Virtual machine ID and name
- Public IP address
- Private IP address
- SQL IaaS extension registration ID
- Storage account name for backups

## SQL IaaS Agent Extension

The deployment automatically registers the SQL Server VM with the SQL IaaS Agent Extension, which provides:

- **Automated Management**: Centralized management of SQL Server settings
- **Automated Patching**: Schedule maintenance windows for SQL Server updates
- **Automated Backup**: Configure backups to Azure Storage
- **Security Compliance**: Azure Security Center integration
- **License Management**: Track and manage SQL Server licenses

## Security Considerations

- The NSG allows RDP (port 3389) and SQL Server (port 1433) from any source. In production, restrict these to specific IP ranges.
- Store the `admin_password` securely using Azure Key Vault or environment variables.
- Consider using Azure Bastion for secure RDP access instead of exposing port 3389.
- Enable encryption for data at rest and in transit.

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

## Available SQL Server Images

Common SQL Server offers and SKUs:
- `sql2019-ws2019` with skus: `standard-gen2`, `enterprise-gen2`, `web-gen2`
- `sql2017-ws2019` with skus: `standard`, `enterprise`, `web`
- `sql2016sp3-ws2019` with skus: `standard`, `enterprise`

## License

This project is provided as-is for demonstration purposes.

## References

- [Azure SQL Virtual Machine Documentation](https://docs.microsoft.com/azure/azure-sql/virtual-machines/)
- [SQL IaaS Agent Extension](https://docs.microsoft.com/azure/azure-sql/virtual-machines/windows/sql-server-iaas-agent-extension-automate-management)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
