# =============================================================================
# WEB SERVER MODULE - Main Configuration
# =============================================================================

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Associate NIC with Load Balancer Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "lb" {
  count                   = var.associate_with_lb ? 1 : 0
  network_interface_id    = azurerm_network_interface.main.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.lb_backend_pool_id
}

# Associate NIC with Load Balancer NAT Rules
resource "azurerm_network_interface_nat_rule_association" "nat" {
  count                 = var.associate_with_lb ? length(var.lb_nat_rule_ids) : 0
  network_interface_id  = azurerm_network_interface.main.id
  ip_configuration_name = "internal"
  nat_rule_id           = var.lb_nat_rule_ids[count.index]
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = var.source_image_version
  }

  tags = var.tags
}

# IIS Installation Extension
resource "azurerm_virtual_machine_extension" "iis" {
  count                = var.install_iis ? 1 : 0
  name                 = "install-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.main.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -Name Web-Server -IncludeManagementTools; $hostname = hostname; $content = '${replace(var.custom_iis_content, "'", "''")}'; $content = $content -replace '\\{hostname\\}', $hostname; Set-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $content\""
  })

  tags = var.tags

  depends_on = [
    azurerm_network_interface_backend_address_pool_association.lb,
    azurerm_network_interface_nat_rule_association.nat
  ]
}
