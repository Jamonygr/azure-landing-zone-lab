# Compute modules

These modules create Windows VMs used throughout the lab. They are primarily used by **Pillar 2: Identity Management** (Domain Controllers) and **Pillar 5: Management** (Jumpbox, Web Servers). They keep VM setup small and predictable so you can focus on networking and platform behavior.

## Module summary

| Module | Purpose | Cost |
|--------|---------|------|
| Windows VM | General-purpose Windows Server | ~$30/month (B2s) |
| Web Server | IIS web server with LB integration | ~$15/month (B1ms) |

## Windows VM (`modules/compute/windows-vm/`)

Creates a NIC, an optional public IP, and a Windows Server VM. Supports data disks and auto-shutdown.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | VM name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `subnet_id` | Subnet for NIC | Required |
| `size` | VM size | `Standard_B2s` |
| `admin_username` | Admin username | Required |
| `admin_password` | Admin password | Required |
| `private_ip` | Static private IP | `null` (dynamic) |
| `create_public_ip` | Create public IP | `false` |
| `windows_sku` | Windows Server SKU | `2022-Datacenter` |
| `availability_zone` | Availability zone | `null` |
| `data_disks` | List of data disks | `[]` |
| `enable_auto_shutdown` | Enable auto-shutdown | `true` |
| `shutdown_time` | Shutdown time (UTC) | `1900` |

**Outputs:** `vm_id`, `vm_name`, `nic_id`, `private_ip`, `public_ip`

### Data disk structure
```hcl
data_disks = [{
  name         = "data-disk-1"
  disk_size_gb = 128
  lun          = 0
  caching      = "ReadWrite"
}]
```

## Web Server (`modules/compute/web-server/`)

Wraps the Windows VM module to stand up IIS web servers. Can join a load balancer backend and NAT rules.

| Input | Description | Default |
|-------|-------------|---------|
| `name` | VM name | Required |
| `resource_group` | Resource group | Required |
| `location` | Azure region | Required |
| `subnet_id` | Subnet for NIC | Required |
| `size` | VM size | `Standard_B1ms` |
| `admin_username` | Admin username | Required |
| `admin_password` | Admin password | Required |
| `associate_with_lb` | Join load balancer | `false` |
| `lb_backend_pool_id` | Backend pool ID | `null` |
| `nat_rule_ids` | NAT rule IDs for RDP | `[]` |
| `install_iis` | Install IIS | `true` |
| `custom_iis_content` | Custom default.htm | `null` |
| `enable_auto_shutdown` | Enable auto-shutdown | `true` |

**Outputs:** `vm_id`, `hostname`, `private_ip`

### Custom IIS content
```hcl
custom_iis_content = <<-EOF
  <html>
  <body>
    <h1>Hello from ${hostname}</h1>
  </body>
  </html>
EOF
```

## Usage patterns

### Domain Controller (Identity pillar)
```hcl
module "dc01" {
  source = "./modules/compute/windows-vm"
  
  name              = "dc01"
  size              = "Standard_B2s"
  private_ip        = "10.1.1.4"  # Static IP for DNS
  create_public_ip  = false
  windows_sku       = "2022-Datacenter"
  enable_auto_shutdown = true
}
```

### Jumpbox (Management pillar)
```hcl
module "jumpbox" {
  source = "./modules/compute/windows-vm"
  
  name              = "jumpbox"
  size              = "Standard_B2s"
  create_public_ip  = var.enable_jumpbox_public_ip
  enable_auto_shutdown = true
}
```

### Web Servers (Workload)
```hcl
module "web_servers" {
  source   = "./modules/compute/web-server"
  count    = var.lb_web_server_count
  
  name              = "web-${count.index + 1}"
  size              = var.lb_web_server_size
  associate_with_lb = true
  lb_backend_pool_id = module.lb.backend_pool_id
  install_iis       = true
}
```

## Cost optimization

| Component | Size | Monthly Cost |
|-----------|------|--------------|
| Domain Controller | Standard_B2s | ~$30 |
| Jumpbox | Standard_B2s | ~$30 |
| Web Server | Standard_B1ms | ~$15 |
| SQL VM | Standard_B2s | ~$30 |

**Tips:**
- Enable `enable_auto_shutdown = true` to reduce costs (default: 7 PM shutdown)
- Use B-series VMs for lab/dev workloads
- Consider Reserved Instances for long-running labs

