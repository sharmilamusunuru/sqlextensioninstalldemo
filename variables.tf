variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "sql-vm-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "sqlvm"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Administrator username for the VM"
  type        = string
  default     = "sqladmin"
}

variable "admin_password" {
  description = "Administrator password for the VM"
  type        = string
  sensitive   = true
}

variable "sql_server_offer" {
  description = "SQL Server offer"
  type        = string
  default     = "sql2019-ws2019"
}

variable "sql_server_sku" {
  description = "SQL Server SKU"
  type        = string
  default     = "standard-gen2"
}

variable "sql_license_type" {
  description = "SQL Server license type (LicenseOnly or PAYG)"
  type        = string
  default     = "PAYG"
  validation {
    condition     = contains(["PAYG", "AHUB", "DR"], var.sql_license_type)
    error_message = "SQL license type must be PAYG, AHUB, or DR."
  }
}

variable "auto_patching_day_of_week" {
  description = "Day of week for automatic patching"
  type        = string
  default     = "Sunday"
  validation {
    condition     = contains(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], var.auto_patching_day_of_week)
    error_message = "Invalid day of week for auto patching."
  }
}
