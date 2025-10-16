#!/bin/bash

# Quick start script for deploying SQL Azure VM with IaaS Agent Extension
# This script helps you get started quickly with the deployment

set -e

echo "=================================="
echo "SQL Azure VM Deployment - Quick Start"
echo "=================================="
echo ""

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    echo "   Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

echo "✅ Terraform is installed"
terraform version
echo ""

# Check if Azure CLI is installed and authenticated
if ! command -v az &> /dev/null; then
    echo "⚠️  Azure CLI is not installed. You'll need to configure Azure credentials manually."
    echo "   Visit: https://docs.microsoft.com/cli/azure/install-azure-cli"
else
    echo "✅ Azure CLI is installed"
    
    # Check if logged in
    if ! az account show &> /dev/null; then
        echo "❌ Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    echo "✅ Logged into Azure"
    SUBSCRIPTION=$(az account show --query name -o tsv)
    echo "   Current subscription: $SUBSCRIPTION"
fi

echo ""
echo "=================================="
echo "Configuration Setup"
echo "=================================="
echo ""

# Create terraform.tfvars if it doesn't exist
if [ ! -f terraform.tfvars ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "✅ Created terraform.tfvars"
    echo ""
    echo "⚠️  IMPORTANT: You need to set the admin_password in terraform.tfvars"
    echo "   Edit the file and uncomment/set the admin_password line."
    echo ""
    read -p "Press Enter to edit terraform.tfvars now, or Ctrl+C to exit..."
    ${EDITOR:-nano} terraform.tfvars
else
    echo "✅ terraform.tfvars already exists"
fi

echo ""
echo "=================================="
echo "Terraform Deployment"
echo "=================================="
echo ""

# Initialize Terraform
echo "Step 1: Initializing Terraform..."
terraform init

echo ""
echo "Step 2: Validating configuration..."
terraform validate

echo ""
echo "Step 3: Formatting files..."
terraform fmt

echo ""
echo "Step 4: Planning deployment..."
terraform plan -out=tfplan

echo ""
echo "=================================="
echo "Ready to Deploy"
echo "=================================="
echo ""
echo "Review the plan above. If everything looks good, the deployment will:"
echo "  - Create a resource group"
echo "  - Deploy networking infrastructure (VNet, Subnet, NSG)"
echo "  - Create a Windows VM with SQL Server"
echo "  - Register with SQL IaaS Agent Extension"
echo "  - Configure automated patching and backups"
echo ""
read -p "Do you want to proceed with the deployment? (yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    echo ""
    echo "Deploying infrastructure..."
    terraform apply tfplan
    
    echo ""
    echo "=================================="
    echo "Deployment Complete! 🎉"
    echo "=================================="
    echo ""
    terraform output
    
    echo ""
    echo "Next steps:"
    echo "  1. Wait a few minutes for SQL Server to fully initialize"
    echo "  2. Connect via RDP using the public IP and credentials"
    echo "  3. Verify SQL IaaS Agent Extension in Azure Portal"
    echo "  4. Test SQL Server connectivity"
    echo ""
    echo "To clean up resources later, run: terraform destroy"
else
    echo "Deployment cancelled."
    rm -f tfplan
fi
