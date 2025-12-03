# =============================================================================
# WINDOWS VIRTUAL MACHINE MODULE - MAIN
# =============================================================================

# Network Interface
resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  timeouts {
    create = "60m"
  }

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.this[0].id : null
  }
}

# Public IP (optional)
resource "azurerm_public_ip" "this" {
  count               = var.enable_public_ip ? 1 : 0
  name                = "pip-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "this" {
  name                = var.name
  computer_name       = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zone                = var.zone
  tags                = var.tags

  timeouts {
    create = "90m"
  }

  network_interface_ids = [azurerm_network_interface.this.id]

  os_disk {
    name                 = "osdisk-${var.name}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Cheapest for lab
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows_sku
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null # Managed storage
  }

  identity {
    type = "SystemAssigned"
  }
}

# Data Disks
resource "azurerm_managed_disk" "data" {
  for_each             = { for disk in var.data_disks : disk.name => disk }
  name                 = "disk-${var.name}-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each           = { for disk in var.data_disks : disk.name => disk }
  managed_disk_id    = azurerm_managed_disk.data[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = each.value.lun
  caching            = "ReadWrite"
}

# Auto-shutdown (cost saving)
resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  count              = var.enable_auto_shutdown ? 1 : 0
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = false
  }

  tags = var.tags
}
