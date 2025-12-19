# =============================================================================
# SECONDARY REGION LANDING ZONE
# West Europe hub with Windows Server 2025 Core VM for cross-region scenarios
# =============================================================================

# Secondary Region Resource Group
resource "azurerm_resource_group" "secondary" {
  name     = "rg-secondary-${var.environment}-${var.location_short}"
  location = var.location
  tags     = var.tags
}

# Secondary Hub VNet
resource "azurerm_virtual_network" "secondary_hub" {
  name                = "vnet-hub-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = azurerm_resource_group.secondary.name
  address_space       = var.address_space
  tags                = var.tags
}

# Management Subnet
resource "azurerm_subnet" "mgmt" {
  name                 = "snet-mgmt-${var.environment}-${var.location_short}"
  resource_group_name  = azurerm_resource_group.secondary.name
  virtual_network_name = azurerm_virtual_network.secondary_hub.name
  address_prefixes     = [var.mgmt_subnet_prefix]
}

# NSG for Management Subnet
resource "azurerm_network_security_group" "mgmt" {
  name                = "nsg-mgmt-${var.environment}-${var.location_short}"
  location            = var.location
  resource_group_name = azurerm_resource_group.secondary.name
  tags                = var.tags

  security_rule {
    name                       = "AllowRDPFromPrimary"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.primary_hub_address_space
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowICMPFromPrimary"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.primary_hub_address_space
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
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

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = azurerm_subnet.mgmt.id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

# =============================================================================
# GLOBAL VNET PEERING (Cross-Region)
# =============================================================================

# Peering from Secondary Hub to Primary Hub
resource "azurerm_virtual_network_peering" "secondary_to_primary" {
  name                         = "peer-secondary-to-primary"
  resource_group_name          = azurerm_resource_group.secondary.name
  virtual_network_name         = azurerm_virtual_network.secondary_hub.name
  remote_virtual_network_id    = var.primary_hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways
}

# Peering from Primary Hub to Secondary Hub (created in primary region)
resource "azurerm_virtual_network_peering" "primary_to_secondary" {
  name                         = "peer-primary-to-secondary"
  resource_group_name          = var.primary_hub_resource_group
  virtual_network_name         = var.primary_hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.secondary_hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.primary_has_gateway
  use_remote_gateways          = false
}

# =============================================================================
# WINDOWS SERVER 2025 CORE VM
# =============================================================================

resource "azurerm_network_interface" "vm" {
  count               = var.deploy_vm ? 1 : 0
  name                = "nic-${var.vm_name}-${var.location_short}"
  location            = var.location
  resource_group_name = azurerm_resource_group.secondary.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.deploy_vm ? 1 : 0
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.secondary.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = merge(var.tags, { Role = "SecondaryRegion-DR" })

  network_interface_ids = [azurerm_network_interface.vm[0].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Windows Server 2025 Datacenter Core
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_sku
    version   = "latest"
  }

  # Enable boot diagnostics with managed storage
  boot_diagnostics {
    storage_account_uri = null # Use managed storage account
  }
}

# Auto-shutdown for cost savings
resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm" {
  count              = var.deploy_vm && var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_windows_virtual_machine.vm[0].id
  location           = var.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }

  tags = var.tags
}
