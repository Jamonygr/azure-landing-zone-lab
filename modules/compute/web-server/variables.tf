# =============================================================================
# WEB SERVER MODULE - Variables
# =============================================================================

variable "name" {
  description = "Name of the web server VM"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM NIC"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1ms"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "source_image_publisher" {
  description = "Publisher of the source image"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "source_image_offer" {
  description = "Offer of the source image"
  type        = string
  default     = "WindowsServer"
}

variable "source_image_sku" {
  description = "SKU of the source image"
  type        = string
  default     = "2022-datacenter-core-smalldisk"
}

variable "source_image_version" {
  description = "Version of the source image"
  type        = string
  default     = "latest"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 64
}

variable "os_disk_type" {
  description = "Type of managed disk"
  type        = string
  default     = "Standard_LRS"
}

variable "lb_backend_pool_id" {
  description = "Load balancer backend pool ID to associate with"
  type        = string
  default     = null
}

variable "lb_nat_rule_ids" {
  description = "List of load balancer NAT rule IDs to associate with"
  type        = list(string)
  default     = []
}

variable "associate_with_lb" {
  description = "Whether to associate with load balancer (avoids count issues)"
  type        = bool
  default     = false
}

variable "install_iis" {
  description = "Install IIS web server"
  type        = bool
  default     = true
}

variable "custom_iis_content" {
  description = "Custom HTML content for IIS default page. Use {hostname} as placeholder."
  type        = string
  default     = "<html><head><title>Azure Web Server</title></head><body><h1>Hello from {hostname}!</h1><p>Load Balancer Test Page</p></body></html>"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
