# Compute modules

These modules create Windows VMs used throughout the lab. They keep VM setup small and predictable so you can focus on networking and platform behavior.

## Windows VM

Creates a NIC, an optional public IP, and a Windows Server VM. Supports data disks and auto-shutdown.  
Inputs: name, resource group, location, subnet ID, size, admin username/password, optional private IP, optional public IP, Windows SKU, availability zone, data disks, `enable_auto_shutdown`, tags.  
Outputs: VM ID and name, NIC ID, private IP, and public IP (if created).

## Web server

Wraps the Windows VM module to stand up IIS web servers. Can join a load balancer backend and NAT rules.  
Inputs: name, resource group, location, subnet ID, VM size, admin username/password, `associate_with_lb`, load balancer backend pool ID, NAT rule IDs, `install_iis`, `custom_iis_content`, tags.  
Outputs: VM ID, hostname, and private IP.

Notes:

- The workload landing zone uses this module to create the sample web tier.  
- IIS content can include placeholders for the hostname so you can see which VM served a page.  
- Auto-shutdown is available to keep lab costs low.
