# 🏗️ Azure Landing Zone Lab - Terraform

[![Terraform](https://img.shields.io/badge/Terraform->=1.9.0-623CE4?logo=terraform)](https://terraform.io)
[![Azure](https://img.shields.io/badge/Azure-AzureRM%204.x-0078D4?logo=microsoftazure)](https://azure.microsoft.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A **production-ready** Azure Landing Zone lab environment built with Terraform, following Microsoft's Cloud Adoption Framework (CAF) best practices. This project deploys a complete enterprise-grade hub-spoke network topology with identity services, security controls, load-balanced web workloads, and optional hybrid connectivity.

> 💡 **Modular Design**: Core infrastructure deploys in ~10-15 minutes. Optional components (VPN Gateway, AKS, Load Balancer) can be enabled when needed.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture Diagram](#-architecture-diagram)
- [What Gets Deployed](#-what-gets-deployed)
- [Optional Components](#-optional-components)
- [Network Topology](#-network-topology)
- [Traffic Flow](#-traffic-flow)
- [Quick Start](#-quick-start)
- [Configuration Options](#-configuration-options)
- [Testing the Load Balancer](#-testing-the-load-balancer)
- [Security Features](#-security-features)
- [Cost Estimation](#-cost-estimation)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

---

## 🎯 Overview

This Terraform project creates a complete Azure Landing Zone lab environment that simulates an enterprise hybrid cloud setup. It includes:

### Core Components (Always Deployed)
- **Hub-Spoke Network Topology** - Centralized connectivity with Azure Firewall
- **Identity Services** - Windows Server Domain Controllers for Active Directory
- **Management Zone** - Jumpbox for secure access and Log Analytics for monitoring
- **Shared Services** - Azure Key Vault for secrets, Storage Account for file shares
- **⚖️ Public Load Balancer with IIS Web Servers** - Load-balanced web tier with automatic IIS installation

### Optional Components (Configurable)
- **🔗 VPN Gateway & Simulated On-Premises** - Site-to-site VPN connectivity for hybrid scenarios
- **☸️ Azure Kubernetes Service (AKS)** - Managed Kubernetes cluster for container workloads
- **🗄️ Azure SQL Database** - Managed relational database with private endpoint

### Use Cases

- 🎓 **Learning** - Practice Azure networking, security, load balancing, and infrastructure as code
- 🧪 **Testing** - Validate architectures before production deployment
- 📚 **Training** - Teach teams about Azure Landing Zones and CAF
- 🔬 **PoC** - Quickly spin up proof-of-concept environments

---

## ⚡ Deployment Profiles

| Profile | Components | Deployment Time | Monthly Cost |
|---------|------------|-----------------|--------------|
| **Standard** | Core + Firewall + Load Balancer + IIS | ~15 min | ~$500 |
| **Full Hybrid** | Standard + VPN + AKS | ~45-60 min | ~$850 |

---

## 🏛️ Architecture Diagram

```
                                    ┌─────────────────────────────────────────────────────────────────────────────────┐
                                    │                              AZURE CLOUD                                        │
                                    │                                                                                 │
                                    │                                  INTERNET                                       │
                                    │                                     │                                           │
                                    │                    ┌────────────────┼────────────────┐                          │
                                    │                    │                │                │                          │
                                    │                    ▼                ▼                ▼                          │
┌─────────────────┐                 │  ┌─────────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│   ON-PREMISES   │                 │  │   Azure Firewall    │  │  Public Load    │  │   VPN Gateway   │             │
│   (Simulated)   │                 │  │   172.191.x.x       │  │    Balancer     │  │   [OPTIONAL]    │             │
│   [OPTIONAL]    │                 │  │   (DNAT/SNAT)       │  │  52.170.x.x     │  │                 │             │
│                 │     VPN         │  └─────────┬───────────┘  └────────┬────────┘  └────────┬────────┘             │
│  ┌───────────┐  │    Tunnel       │            │                       │                    │                      │
│  │ File      │◄─┼─────────────────┼────────────┼───────────────────────┼────────────────────┘                      │
│  │ Server    │  │                 │            │                       │                                           │
│  │10.100.1.4 │  │                 │            │                       │                                           │
│  └───────────┘  │                 │  ┌─────────┴───────────────────────┴───────────────────────────────────────┐   │
│                 │                 │  │                        HUB VNET (10.0.0.0/16)                           │   │
│  VNet:          │                 │  │                                                                         │   │
│  10.100.0.0/16  │                 │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐          │   │
└─────────────────┘                 │  │  │  Gateway    │  │  Firewall   │  │    Management Subnet    │          │   │
                                    │  │  │   Subnet    │  │   Subnet    │  │      (10.0.2.0/24)      │          │   │
                                    │  │  │ 10.0.0.0/24 │  │ 10.0.1.0/24 │  └─────────────────────────┘          │   │
                                    │  │  └─────────────┘  └─────────────┘                                       │   │
                                    │  └─────────────────────────────────────────────────────────────────────────┘   │
                                    │                │                │                │                              │
                                    │                │    VNet Peerings (Hub-Spoke)    │                              │
                                    │    ┌───────────┴────────────────┬────────────────┴───────────┐                  │
                                    │    │                            │                            │                  │
                                    │    ▼                            ▼                            ▼                  │
                                    │  ┌──────────────┐        ┌──────────────┐        ┌──────────────┐              │
                                    │  │  IDENTITY    │        │  MANAGEMENT  │        │   SHARED     │              │
                                    │  │   VNET       │        │    VNET      │        │  SERVICES    │              │
                                    │  │ 10.1.0.0/16  │        │ 10.2.0.0/16  │        │ 10.3.0.0/16  │              │
                                    │  │              │        │              │        │              │              │
                                    │  │ ┌──────────┐ │        │ ┌──────────┐ │        │ ┌──────────┐ │              │
                                    │  │ │  DC01    │ │        │ │ Jumpbox  │ │        │ │Key Vault │ │              │
                                    │  │ │ (Win22)  │ │        │ │ (Win22)  │ │        │ │          │ │              │
                                    │  │ │10.1.1.4  │ │        │ │10.2.1.4  │ │        │ └──────────┘ │              │
                                    │  │ └──────────┘ │        │ └──────────┘ │        │ ┌──────────┐ │              │
                                    │  │ ┌──────────┐ │        │ ┌──────────┐ │        │ │ Storage  │ │              │
                                    │  │ │  DC02    │ │        │ │   Log    │ │        │ │ Account  │ │              │
                                    │  │ │[Optional]│ │        │ │Analytics │ │        │ │          │ │              │
                                    │  │ │10.1.1.5  │ │        │ └──────────┘ │        │ └──────────┘ │              │
                                    │  │ └──────────┘ │        └──────────────┘        └──────────────┘              │
                                    │  └──────────────┘                                                               │
                                    │                                                                                 │
                                    │                                    │                                            │
                                    │                                    ▼                                            │
                                    │  ┌──────────────────────────────────────────────────────────────────────────┐  │
                                    │  │                    WORKLOAD PROD VNET (10.10.0.0/16)                     │  │
                                    │  │                                                                          │  │
                                    │  │   ┌────────────────────────────────────────────────────────────────┐    │  │
                                    │  │   │                 WEB SUBNET (10.10.1.0/24)                       │    │  │
                                    │  │   │                                                                 │    │  │
                                    │  │   │                    PUBLIC LOAD BALANCER                         │    │  │
                                    │  │   │                      52.170.128.134                             │    │  │
                                    │  │   │                           │                                     │    │  │
                                    │  │   │              ┌────────────┴────────────┐                        │    │  │
                                    │  │   │              │                         │                        │    │  │
                                    │  │   │              ▼                         ▼                        │    │  │
                                    │  │   │   ┌───────────────────┐     ┌───────────────────┐               │    │  │
                                    │  │   │   │    web01-prd      │     │    web02-prd      │               │    │  │
                                    │  │   │   │   Windows IIS     │     │   Windows IIS     │               │    │  │
                                    │  │   │   │   10.10.1.5       │     │   10.10.1.4       │               │    │  │
                                    │  │   │   │   Standard_B1ms   │     │   Standard_B1ms   │               │    │  │
                                    │  │   │   └───────────────────┘     └───────────────────┘               │    │  │
                                    │  │   │                                                                 │    │  │
                                    │  │   │   Health Probe: HTTP/80    LB Rule: TCP/80 → Backend Pool       │    │  │
                                    │  │   │   NAT Rules: 3389→web01, 3390→web02                             │    │  │
                                    │  │   └─────────────────────────────────────────────────────────────────┘    │  │
                                    │  │                                                                          │  │
                                    │  │   ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐       │  │
                                    │  │   │   App Subnet    │   │  Data Subnet    │   │   AKS Subnet    │       │  │
                                    │  │   │  10.10.2.0/24   │   │  10.10.3.0/24   │   │  10.10.64.0/18  │       │  │
                                    │  │   │   [OPTIONAL]    │   │   [OPTIONAL]    │   │   [OPTIONAL]    │       │  │
                                    │  │   └─────────────────┘   └─────────────────┘   └─────────────────┘       │  │
                                    │  │                                                                          │  │
                                    │  └──────────────────────────────────────────────────────────────────────────┘  │
                                    └─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Traffic Flow

### Load Balancer Traffic (Separate from Firewall)

```
                                    INTERNET
                                        │
                    ┌───────────────────┴───────────────────┐
                    │                                       │
                    ▼                                       ▼
        ┌───────────────────────┐               ┌───────────────────────┐
        │   Azure Firewall      │               │   Public Load         │
        │   172.191.184.142     │               │   Balancer            │
        │                       │               │   52.170.128.134      │
        │   • Outbound SNAT     │               │                       │
        │   • Spoke traffic     │               │   • HTTP/80 → VMs     │
        │   • App-to-App        │               │   • Health probes     │
        └───────────┬───────────┘               │   • 5-tuple hash LB   │
                    │                           └───────────┬───────────┘
                    │                                       │
                    │         ┌─────────────────────────────┘
                    │         │
                    ▼         ▼
        ┌─────────────────────────────────────────────────────────────┐
        │                    WEB SUBNET (10.10.1.0/24)                 │
        │                                                              │
        │   ┌──────────────────┐          ┌──────────────────┐        │
        │   │   web01-prd      │          │   web02-prd      │        │
        │   │   10.10.1.5      │          │   10.10.1.4      │        │
        │   │   IIS Web Server │          │   IIS Web Server │        │
        │   └──────────────────┘          └──────────────────┘        │
        │                                                              │
        │   Route Table: Default (Internet) - NO firewall routing     │
        │   This enables symmetric routing for Load Balancer          │
        └─────────────────────────────────────────────────────────────┘
```

### Why Web Subnet Bypasses Firewall

When using a **Public Load Balancer**, the web subnet must have direct internet routing to avoid **asymmetric routing**:

| Scenario | Inbound Path | Outbound Path | Result |
|----------|--------------|---------------|--------|
| ❌ Web subnet with FW route | LB → VM | VM → Firewall → Internet | **Broken** (TCP fails) |
| ✅ Web subnet direct | LB → VM | VM → Internet | **Works** (symmetric) |

The configuration automatically excludes the web subnet from firewall routing when the public load balancer is enabled.

---

## 📦 What Gets Deployed

### Resource Groups

| Resource Group | Purpose | Optional |
|----------------|---------|----------|
| `rg-hub-{env}-{location}` | Hub networking, Firewall | No |
| `rg-identity-{env}-{location}` | Domain Controllers | No |
| `rg-management-{env}-{location}` | Jumpbox, Log Analytics | No |
| `rg-shared-{env}-{location}` | Key Vault, Storage | No |
| `rg-workload-prod-{env}-{location}` | Load Balancer, Web Servers | No (Core) |
| `rg-onprem-{env}-{location}` | Simulated on-premises | **Yes** |

### Load Balancer Resources

| Resource | Configuration | Purpose |
|----------|---------------|---------|
| **Public Load Balancer** | Standard SKU | Distributes HTTP traffic |
| **Frontend IP** | Static public IP | Internet entry point |
| **Backend Pool** | 2 Web Servers | Target VMs |
| **Health Probe** | HTTP/80, 5s interval | VM health monitoring |
| **LB Rule (HTTP)** | TCP/80 → 80 | Web traffic distribution |
| **LB Rule (HTTPS)** | TCP/443 → 443 | Secure web traffic |
| **NAT Rule (RDP web01)** | TCP/3389 → 3389 | Direct RDP to web01 |
| **NAT Rule (RDP web02)** | TCP/3390 → 3389 | Direct RDP to web02 |
| **Outbound Rule** | SNAT via LB PIP | Outbound internet access |

### Web Server Resources

| Resource | Configuration | Purpose |
|----------|---------------|---------|
| **web01-prd** | Windows Server 2022 Core, Standard_B1ms | IIS Web Server |
| **web02-prd** | Windows Server 2022 Core, Standard_B1ms | IIS Web Server |
| **NIC (each)** | Backend pool + NAT association | Network connectivity |
| **IIS Extension** | CustomScriptExtension | Auto-install IIS + custom page |

---

## 🌐 Network Topology

### Address Space Allocation

| Network | CIDR | Purpose |
|---------|------|---------|
| **Hub** | 10.0.0.0/16 | Central connectivity hub |
| ├─ GatewaySubnet | 10.0.0.0/24 | VPN Gateway |
| ├─ AzureFirewallSubnet | 10.0.1.0/24 | Azure Firewall |
| └─ ManagementSubnet | 10.0.2.0/24 | Hub management |
| **Identity** | 10.1.0.0/16 | Domain Controllers |
| └─ DCSubnet | 10.1.1.0/24 | DC01 (10.1.1.4), DC02 (10.1.1.5) |
| **Management** | 10.2.0.0/16 | Operations |
| └─ JumpboxSubnet | 10.2.1.0/24 | Jumpbox (10.2.1.4) |
| **Shared** | 10.3.0.0/16 | Shared services |
| └─ PrivateEndpointSubnet | 10.3.1.0/24 | Private endpoints |
| **Workload Prod** | 10.10.0.0/16 | Production apps |
| ├─ WebSubnet | 10.10.1.0/24 | **Load Balanced Web Tier** |
| ├─ AppSubnet | 10.10.2.0/24 | App tier VMs |
| ├─ DataSubnet | 10.10.3.0/24 | Database VMs |
| └─ AKSSubnet | 10.10.64.0/18 | AKS node pool |
| **On-Premises** | 10.100.0.0/16 | Simulated on-prem |

---

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://terraform.io/downloads) >= 1.9.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) >= 2.50.0
- Azure subscription with Owner or Contributor access

### Step 1: Clone and Configure

```bash
git clone https://github.com/Jamonygr/azure-landing-zone-lab.git
cd azure-landing-zone-lab

# Copy example config
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
code terraform.tfvars
```

### Step 2: Deploy

```bash
# Login to Azure
az login

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

### Step 3: Verify Load Balancer

```bash
# Get the Load Balancer IP
terraform output lb_frontend_ip

# Test with curl (should alternate between web01-prd and web02-prd)
curl http://$(terraform output -raw lb_frontend_ip)
```

---

## ⚙️ Configuration Options

### terraform.tfvars

```hcl
# =============================================================================
# CORE SETTINGS
# =============================================================================
project     = "azlab"
environment = "lab"
location    = "eastus"

# =============================================================================
# LOAD BALANCER CONFIGURATION (Always Deployed)
# =============================================================================
lb_type              = "public"          # public or internal
lb_web_server_count  = 2                 # Number of web servers (1-10)
lb_web_server_size   = "Standard_B1ms"   # VM size (2GB RAM min for IIS)

# =============================================================================
# OPTIONAL COMPONENTS
# =============================================================================
deploy_vpn_gateway       = false         # VPN Gateway (~30 min deploy)
deploy_onprem_simulation = false         # Simulated on-premises
deploy_aks               = false         # Azure Kubernetes Service
deploy_sql               = false         # Azure SQL Database

# =============================================================================
# SECURITY
# =============================================================================
admin_username = "azureadmin"
admin_password = "YourSecurePassword123!"  # Change this!

# =============================================================================
# COST OPTIMIZATION
# =============================================================================
enable_auto_shutdown = true              # VMs shutdown at 7 PM
vm_size              = "Standard_B2s"    # Default VM size
```

---

## 🧪 Testing the Load Balancer

### Access URLs

| Service | URL | Notes |
|---------|-----|-------|
| **HTTP (Load Balanced)** | `http://<lb_frontend_ip>` | Distributes to both VMs |
| **RDP to web01** | `<lb_frontend_ip>:3389` | NAT rule direct access |
| **RDP to web02** | `<lb_frontend_ip>:3390` | NAT rule direct access |

### Verify Load Balancing

```powershell
# From your local machine - run multiple times
# You should see responses from both web01-prd and web02-prd
curl http://52.170.128.134

# From different source IPs (different connections)
# Azure LB uses 5-tuple hash: Source IP, Source Port, Dest IP, Dest Port, Protocol
```

### Expected Response

```html
<h1>web01-prd</h1>
<p>Azure Landing Zone - prod Workload</p>
<p>Load Balanced Web Server</p>
```

### Health Check

```bash
# Check backend pool health
az network lb show \
  --resource-group rg-workload-prod-lab-east \
  --name lb-prod-lab-east \
  --query "loadBalancingRules[].backendAddressPool.id" -o table

# Check probe status
az network lb probe list \
  --resource-group rg-workload-prod-lab-east \
  --lb-name lb-prod-lab-east -o table
```

---

## 🔒 Security Features

### Network Security

| Feature | Implementation |
|---------|----------------|
| **Azure Firewall** | Centralized egress control with DNAT/SNAT |
| **NSG Rules** | Subnet-level traffic filtering |
| **Route Tables** | Forced tunneling through firewall (except web subnet for LB) |
| **Private Endpoints** | Private access to PaaS services |

### Load Balancer Security

| Feature | Configuration |
|---------|---------------|
| **Standard SKU** | Secure by default (no public access without rules) |
| **Health Probes** | Only healthy VMs receive traffic |
| **NSG Integration** | NSG rules required to allow traffic |
| **Outbound Rules** | Controlled SNAT for internet access |

### Web Subnet NSG Rules

| Priority | Name | Direction | Access | Port | Source |
|----------|------|-----------|--------|------|--------|
| 100 | AllowHTTP | Inbound | Allow | 80 | * |
| 110 | AllowHTTPS | Inbound | Allow | 443 | * |
| 200 | AllowRDPFromHub | Inbound | Allow | 3389 | Hub VNet |

---

## 💰 Cost Estimation

### Monthly Cost Breakdown (Standard Profile)

| Resource | SKU | Monthly Cost |
|----------|-----|--------------|
| Azure Firewall | Standard | ~$350 |
| Public Load Balancer | Standard | ~$25 |
| Web Servers (2x) | Standard_B1ms | ~$30 |
| Domain Controllers (1-2x) | Standard_B2s | ~$60 |
| Jumpbox | Standard_B2s | ~$30 |
| Storage Account | Standard_LRS | ~$5 |
| Log Analytics | PerGB2018 | ~$10 |
| **Total** | | **~$510/month** |

> 💡 **Cost Saving Tips:**
> - Enable `auto_shutdown` for VMs (saves ~50% on VM costs)
> - Use `Standard_B1ms` for web servers (sufficient for IIS)
> - Disable VPN Gateway when not testing hybrid scenarios

---

## 🔧 Troubleshooting

### Load Balancer Not Responding

```bash
# Check if VMs are in backend pool
az network nic show \
  --resource-group rg-workload-prod-lab-east \
  --name nic-web01-prd \
  --query "ipConfigurations[0].loadBalancerBackendAddressPools" -o table

# Check health probe status
az network lb probe list \
  --resource-group rg-workload-prod-lab-east \
  --lb-name lb-prod-lab-east -o table

# Verify NSG allows HTTP
az network nsg rule list \
  --resource-group rg-workload-prod-lab-east \
  --nsg-name nsg-web-prod-lab-east -o table
```

### Asymmetric Routing Issues

If you see the load balancer timing out:

1. **Check route table association** - Web subnet should NOT have firewall route when using public LB
2. **Verify** `lb_type = "public"` in terraform.tfvars
3. **Confirm** web subnet is excluded from route table in `landing-zones/workload/main.tf`

### IIS Not Installed

```powershell
# RDP to the VM via NAT rule
mstsc /v:<lb_frontend_ip>:3389  # web01
mstsc /v:<lb_frontend_ip>:3390  # web02

# Check IIS status
Get-WindowsFeature -Name Web-Server

# Manually install if needed
Install-WindowsFeature -Name Web-Server -IncludeManagementTools
```

---

## 📁 Project Structure

```
azure-landing-zone-lab/
├── main.tf                    # Root module - orchestrates all resources
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars           # Configuration values
├── locals.tf                  # Local variables
│
├── landing-zones/
│   ├── hub/                   # Hub VNet, Firewall, VPN Gateway
│   ├── identity/              # Domain Controllers
│   ├── management/            # Jumpbox, Log Analytics
│   ├── shared-services/       # Key Vault, Storage
│   ├── workload/              # Load Balancer, Web Servers, AKS
│   └── onprem-simulated/      # Simulated on-premises
│
└── modules/
    ├── networking/
    │   ├── load-balancer/     # ⭐ Azure Load Balancer module
    │   ├── vnet/
    │   ├── subnet/
    │   ├── nsg/
    │   ├── peering/
    │   ├── route-table/
    │   ├── vpn-gateway/
    │   └── ...
    ├── compute/
    │   ├── web-server/        # ⭐ IIS Web Server module
    │   └── windows-vm/
    ├── firewall/
    ├── firewall-rules/
    ├── keyvault/
    ├── storage/
    └── monitoring/
```

---

## 📚 Modules Reference

### Load Balancer Module (`modules/networking/load-balancer/`)

```hcl
module "load_balancer" {
  source = "./modules/networking/load-balancer"

  name                = "lb-prod-lab-east"
  resource_group_name = "rg-workload-prod-lab-east"
  location            = "eastus"
  sku                 = "Standard"
  type                = "public"        # or "internal"
  subnet_id           = null            # Required if type = "internal"
  private_ip_address  = null            # Optional static IP for internal

  health_probes = {
    http = {
      protocol     = "Http"
      port         = 80
      request_path = "/"
    }
  }

  lb_rules = {
    http = {
      protocol      = "Tcp"
      frontend_port = 80
      backend_port  = 80
      probe_name    = "http"
    }
  }

  nat_rules = {
    rdp-web01 = { protocol = "Tcp", frontend_port = 3389, backend_port = 3389 }
    rdp-web02 = { protocol = "Tcp", frontend_port = 3390, backend_port = 3389 }
  }
}
```

### Web Server Module (`modules/compute/web-server/`)

```hcl
module "web_server" {
  source = "./modules/compute/web-server"

  name                = "web01-prd"
  resource_group_name = "rg-workload-prod-lab-east"
  location            = "eastus"
  subnet_id           = module.web_subnet.id
  vm_size             = "Standard_B1ms"
  admin_username      = "azureadmin"
  admin_password      = "SecurePassword123!"

  # Load Balancer association
  associate_with_lb  = true
  lb_backend_pool_id = module.load_balancer.backend_pool_id
  lb_nat_rule_ids    = [module.load_balancer.nat_rule_ids["rdp-web01"]]

  # IIS configuration
  install_iis        = true
  custom_iis_content = "<h1>{hostname}</h1><p>Custom content</p>"
}
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Microsoft Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Landing Zones](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

---

**Built with ❤️ for learning Azure infrastructure**
