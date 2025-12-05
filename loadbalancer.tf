# =============================================================================
# LOAD BALANCER LAB - Complete Example with 2 Windows Server Core VMs
# =============================================================================

locals {
  lb_location       = "East US"
  lb_admin_username = "azureadmin"
  lb_admin_password = "P@ssw0rd123!Lab"
}

# -----------------------------------------------------------------------------
# RESOURCE GROUP
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "lb_rg" {
  name     = "rg-loadbalancer-lab"
  location = local.lb_location
}

# -----------------------------------------------------------------------------
# NETWORKING - VNet, Subnet, NSG
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "lb_vnet" {
  name                = "vnet-lb-lab"
  address_space       = ["10.50.0.0/16"]
  location            = local.lb_location
  resource_group_name = azurerm_resource_group.lb_rg.name
}

resource "azurerm_subnet" "lb_subnet" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.lb_rg.name
  virtual_network_name = azurerm_virtual_network.lb_vnet.name
  address_prefixes     = ["10.50.1.0/24"]
}

resource "azurerm_network_security_group" "lb_nsg" {
  name                = "nsg-web"
  location            = local.lb_location
  resource_group_name = azurerm_resource_group.lb_rg.name

  # Allow HTTP from internet
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS from internet
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow RDP from internet (for NAT rules)
  security_rule {
    name                       = "AllowRDP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "lb_nsg_assoc" {
  subnet_id                 = azurerm_subnet.lb_subnet.id
  network_security_group_id = azurerm_network_security_group.lb_nsg.id
}

# -----------------------------------------------------------------------------
# PUBLIC IP FOR LOAD BALANCER
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "lb_pip" {
  name                = "pip-lb-frontend"
  location            = local.lb_location
  resource_group_name = azurerm_resource_group.lb_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# -----------------------------------------------------------------------------
# LOAD BALANCER
# -----------------------------------------------------------------------------
resource "azurerm_lb" "lb" {
  name                = "lb-web"
  location            = local.lb_location
  resource_group_name = azurerm_resource_group.lb_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "lb_backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backend-pool"
}

# -----------------------------------------------------------------------------
# HEALTH PROBES
# -----------------------------------------------------------------------------
# HTTP Health Probe - checks if IIS is responding
resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

# TCP Health Probe - for RDP check
resource "azurerm_lb_probe" "rdp_probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "rdp-probe"
  protocol        = "Tcp"
  port            = 3389
}

# -----------------------------------------------------------------------------
# INBOUND LOAD BALANCING RULES
# -----------------------------------------------------------------------------
# HTTP Load Balancing Rule - distributes port 80 traffic across VMs
resource "azurerm_lb_rule" "http_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
  disable_outbound_snat          = true
  idle_timeout_in_minutes        = 4
  load_distribution              = "Default"
}

# HTTPS Load Balancing Rule
resource "azurerm_lb_rule" "https_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "https-rule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
  disable_outbound_snat          = true
  idle_timeout_in_minutes        = 4
  load_distribution              = "SourceIP"
}

# -----------------------------------------------------------------------------
# NAT RULES - RDP to individual VMs
# -----------------------------------------------------------------------------
# NAT Rule: Port 3389 -> Web01 RDP
resource "azurerm_lb_nat_rule" "rdp_web01" {
  resource_group_name            = azurerm_resource_group.lb_rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "rdp-to-web01"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "frontend"
}

# NAT Rule: Port 3390 -> Web02 RDP
resource "azurerm_lb_nat_rule" "rdp_web02" {
  resource_group_name            = azurerm_resource_group.lb_rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "rdp-to-web02"
  protocol                       = "Tcp"
  frontend_port                  = 3390
  backend_port                   = 3389
  frontend_ip_configuration_name = "frontend"
}

# -----------------------------------------------------------------------------
# OUTBOUND RULE - SNAT for internet access from VMs
# -----------------------------------------------------------------------------
resource "azurerm_lb_outbound_rule" "outbound" {
  name                    = "outbound-rule"
  loadbalancer_id         = azurerm_lb.lb.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id

  frontend_ip_configuration {
    name = "frontend"
  }
}

# -----------------------------------------------------------------------------
# WINDOWS SERVER CORE VMs - Web01 and Web02
# -----------------------------------------------------------------------------

# NIC for Web01
resource "azurerm_network_interface" "web01_nic" {
  name                = "nic-web01"
  location            = local.lb_location
  resource_group_name = azurerm_resource_group.lb_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lb_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# NIC for Web02
resource "azurerm_network_interface" "web02_nic" {
  name                = "nic-web02"
  location            = local.lb_location
  resource_group_name = azurerm_resource_group.lb_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lb_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate Web01 NIC with Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "web01_backend" {
  network_interface_id    = azurerm_network_interface.web01_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id
}

# Associate Web02 NIC with Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "web02_backend" {
  network_interface_id    = azurerm_network_interface.web02_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id
}

# Associate Web01 NIC with NAT Rule
resource "azurerm_network_interface_nat_rule_association" "web01_nat" {
  network_interface_id  = azurerm_network_interface.web01_nic.id
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.rdp_web01.id
}

# Associate Web02 NIC with NAT Rule
resource "azurerm_network_interface_nat_rule_association" "web02_nat" {
  network_interface_id  = azurerm_network_interface.web02_nic.id
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.rdp_web02.id
}

# Web01 VM - Windows Server Core with IIS
resource "azurerm_windows_virtual_machine" "web01" {
  name                = "web01"
  resource_group_name = azurerm_resource_group.lb_rg.name
  location            = local.lb_location
  size                = "Standard_B1ms"
  admin_username      = local.lb_admin_username
  admin_password      = local.lb_admin_password

  network_interface_ids = [azurerm_network_interface.web01_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-core-smalldisk"
    version   = "latest"
  }
}

# Web02 VM - Windows Server Core with IIS
resource "azurerm_windows_virtual_machine" "web02" {
  name                = "web02"
  resource_group_name = azurerm_resource_group.lb_rg.name
  location            = local.lb_location
  size                = "Standard_B1ms"
  admin_username      = local.lb_admin_username
  admin_password      = local.lb_admin_password

  network_interface_ids = [azurerm_network_interface.web02_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-core-smalldisk"
    version   = "latest"
  }
}

# -----------------------------------------------------------------------------
# VM EXTENSIONS - Install IIS on both VMs
# -----------------------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "web01_iis" {
  name                 = "install-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.web01.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -Name Web-Server -IncludeManagementTools; Set-Content -Path 'C:\\inetpub\\wwwroot\\index.html' -Value '<html><body><h1>Hello from WEB01</h1></body></html>'\""
  }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "web02_iis" {
  name                 = "install-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.web02.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -Name Web-Server -IncludeManagementTools; Set-Content -Path 'C:\\inetpub\\wwwroot\\index.html' -Value '<html><body><h1>Hello from WEB02</h1></body></html>'\""
  }
  SETTINGS
}

# -----------------------------------------------------------------------------
# OUTPUTS
# -----------------------------------------------------------------------------
output "lb_public_ip" {
  description = "Load Balancer Public IP - Access website here"
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "web_url" {
  description = "Website URL"
  value       = "http://${azurerm_public_ip.lb_pip.ip_address}"
}

output "rdp_web01" {
  description = "RDP to Web01"
  value       = "${azurerm_public_ip.lb_pip.ip_address}:3389"
}

output "rdp_web02" {
  description = "RDP to Web02"
  value       = "${azurerm_public_ip.lb_pip.ip_address}:3390"
}

output "web01_private_ip" {
  description = "Web01 Private IP"
  value       = azurerm_network_interface.web01_nic.private_ip_address
}

output "web02_private_ip" {
  description = "Web02 Private IP"
  value       = azurerm_network_interface.web02_nic.private_ip_address
}