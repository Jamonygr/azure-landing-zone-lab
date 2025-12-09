# 🏗️ Azure Landing Zone Lab

[![Terraform](https://img.shields.io/badge/Terraform->=1.9.0-623CE4?logo=terraform)](https://terraform.io)
[![Azure](https://img.shields.io/badge/Azure-AzureRM%204.x-0078D4?logo=microsoftazure)](https://azure.microsoft.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Learn Azure the right way—by building it. This Terraform project deploys a complete enterprise cloud environment you can explore, break, and rebuild. Covers networking, security, hybrid connectivity, containers, and Windows workloads following Microsoft Cloud Adoption Framework (CAF) best practices.

> 💡 **Hands-on Learning**: Deploy real enterprise infrastructure in minutes. Perfect for Azure certifications (AZ-104, AZ-305, AZ-700), team training, or validating architectures before production.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture Diagram](#-architecture-diagram)
- [Lab Scenarios](#-lab-scenarios)
- [What Gets Deployed](#-what-gets-deployed)
- [Optional Components](#-optional-components)
- [Network Topology](#-network-topology)
- [Traffic Flow](#-traffic-flow)
- [Quick Start](#-quick-start)
- [Configuration Options](#-configuration-options)
- [Testing the Environment](#-testing-the-environment)
- [Security Features](#-security-features)
- [Cost Estimation](#-cost-estimation)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

---

## 🎯 Overview

This Terraform project creates a complete Azure Landing Zone lab environment that simulates an enterprise hybrid cloud setup. Perfect for learning, training, and proof-of-concept work.

### Core Components (Always Deployed)
- **🌐 Hub-Spoke Network Topology** - Centralized connectivity with Azure Firewall
- **🔐 Identity Services** - Windows Server Domain Controllers for Active Directory
- **🖥️ Management Zone** - Jumpbox for secure access and Log Analytics for monitoring
- **🔑 Shared Services** - Azure Key Vault for secrets, Storage Account for file shares, Azure SQL Database
- **⚖️ Load Balanced Web Tier** - IIS Web Servers behind Azure Load Balancer
- **🛡️ Azure Firewall** - Central network security with DNAT/SNAT rules
- **📊 Monitoring & Alerts** - Log Analytics, diagnostic settings, and metric alerts

### Optional Components (Configurable)
- **🔗 VPN Gateway & Simulated On-Premises** - Site-to-site VPN connectivity for hybrid scenarios
- **☸️ Azure Kubernetes Service (AKS)** - Managed Kubernetes cluster for container workloads
- **🛡️ Application Gateway with WAF** - Layer 7 load balancing and web application firewall

### ☁️ PaaS Services (Cloud-Native Workloads)
| Service | Description | Cost |
|---------|-------------|------|
| 🔷 **Azure Functions** | Serverless compute | FREE (Consumption) |
| 🌐 **Static Web Apps** | Modern web hosting | FREE |
| ⚡ **Logic Apps** | Workflow automation | Pay per execution |
| 📬 **Event Grid** | Event-driven messaging | FREE (100k ops/month) |
| 🚌 **Service Bus** | Enterprise messaging | ~$0.05/month |
| 🌍 **App Service** | Web app hosting | ~$13/month |
| 📦 **Container Apps** | Managed containers | ~$5/month |
| 🗃️ **Cosmos DB** | NoSQL database | ~$0-5/month |

### 🎯 Use Cases

| Use Case | Description |
|----------|-------------|
| 🎓 **Learning** | Practice Azure networking, security, load balancing, and IaC |
| 🧪 **Testing** | Validate architectures before production deployment |
| 📚 **Training** | Teach teams about Azure Landing Zones and CAF |
| 🔬 **PoC** | Quickly spin up proof-of-concept environments |
| 🏆 **Certification Prep** | Hands-on practice for AZ-104, AZ-305, AZ-700 exams |

---

## ⚡ Deployment Profiles

| Profile | Components | Deploy Time | Monthly Cost |
|---------|------------|-------------|--------------|
| **Minimal** | Core VNets + Identity + Management | ~10 min | ~$150 |
| **Standard** | Minimal + Firewall + Load Balancer + IIS | ~20 min | ~$500 |
| **Standard + PaaS** | Standard + All PaaS Services | ~35 min | ~$560 |
| **Full Hybrid** | Standard + VPN + On-Prem Simulation | ~45 min | ~$700 |
| **Enterprise** | Full Hybrid + AKS + App Gateway | ~60 min | ~$950 |

---

## 🏛️ Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                              AZURE CLOUD                                                              │
│                                                                                                                       │
│                                                 INTERNET                                                              │
│                                                     │                                                                 │
│                          ┌──────────────────────────┼──────────────────────────┐                                      │
│                          │                          │                          │                                      │
│                          ▼                          ▼                          ▼                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                      HUB VNET (10.0.0.0/16)                                                    │   │
│  │                                                                                                                │   │
│  │   ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                     │   │
│  │   │  GatewaySubnet  │    │ AzureFirewall   │    │   AppGateway    │    │  Management     │                     │   │
│  │   │  10.0.0.0/24    │    │  Subnet         │    │   Subnet        │    │  Subnet         │                     │   │
│  │   │                 │    │  10.0.1.0/24    │    │   10.0.3.0/24   │    │  10.0.2.0/24    │                     │   │
│  │   │  ┌───────────┐  │    │                 │    │                 │    └─────────────────┘                     │   │
│  │   │  │    VPN    │  │    │  ┌───────────┐  │    │  ┌───────────┐  │                                            │   │
│  │   │  │  Gateway  │  │    │  │  Azure    │  │    │  │  App GW   │  │        ┌─────────────────────────────┐     │   │
│  │   │  │[OPTIONAL] │  │    │  │ Firewall  │  │    │  │   WAF     │  │        │  📊 Azure Monitor           │     │   │
│  │   │  └───────────┘  │    │  │ (SNAT/    │  │    │  │[OPTIONAL] │  │        │  • Log Analytics           │     │   │
│  │   │       │         │    │  │  DNAT)    │  │    │  └───────────┘  │        │  • Diagnostic Settings     │     │   │
│  │   └───────┼─────────┘    │  └───────────┘  │    └─────────────────┘        │  • Metric Alerts           │     │   │
│  │           │              │       │         │                               └─────────────────────────────┘     │   │
│  │           │              └───────┼─────────┘                                                                   │   │
│  └───────────┼──────────────────────┼─────────────────────────────────────────────────────────────────────────────┘   │
│              │                      │                                                                                 │
│   ═══════════╬══════════════════════╬═════════════════════════════════════════════════════════════════════════════    │
│   VPN Tunnel ║                      │            VNet Peerings (Hub-Spoke Topology)                                   │
│   ═══════════╬══════════════════════╬═════════════════════════════════════════════════════════════════════════════    │
│              ║                      │                                                                                 │
│              ║          ┌───────────┴────────────────┬────────────────┬────────────────────────┐                     │
│              ║          │                            │                │                        │                     │
│              ▼          ▼                            ▼                ▼                        ▼                     │
│  ┌───────────────────┐ ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────────────┐   │
│  │   ON-PREMISES     │ │   IDENTITY       │  │   MANAGEMENT     │  │    SHARED        │  │   WORKLOAD PROD       │   │
│  │   (Simulated)     │ │   10.1.0.0/16    │  │   10.2.0.0/16    │  │   SERVICES       │  │   10.10.0.0/16        │   │
│  │   [OPTIONAL]      │ │                  │  │                  │  │   10.3.0.0/16    │  │                       │   │
│  │   10.100.0.0/16   │ │ ┌──────────────┐ │  │ ┌──────────────┐ │  │                  │  │ ┌───────────────────┐ │   │
│  │                   │ │ │     DC01     │ │  │ │   Jumpbox    │ │  │ ┌──────────────┐ │  │ │   Web Subnet      │ │   │
│  │ ┌───────────────┐ │ │ │  (Win 2022)  │ │  │ │  (Win 2022)  │ │  │ │  Key Vault   │ │  │ │   10.10.1.0/24    │ │   │
│  │ │  File Server  │ │ │ │  10.1.1.4    │ │  │ │  10.2.1.4    │ │  │ └──────────────┘ │  │ │                   │ │   │
│  │ │  (Win 2022)   │ │ │ └──────────────┘ │  │ └──────────────┘ │  │ ┌──────────────┐ │  │ │  ┌─────┐ ┌─────┐  │ │   │
│  │ │  10.100.1.4   │ │ │ ┌──────────────┐ │  │ ┌──────────────┐ │  │ │   Storage    │ │  │ │  │Web01│ │Web02│  │ │   │
│  │ └───────────────┘ │ │ │     DC02     │ │  │ │     Log      │ │  │ │   Account    │ │  │ │  │ IIS │ │ IIS │  │ │   │
│  │ ┌───────────────┐ │ │ │  [Optional]  │ │  │ │  Analytics   │ │  │ └──────────────┘ │  │ │  └─────┘ └─────┘  │ │   │
│  │ │  VPN Gateway  │ │ │ │  10.1.1.5    │ │  │ └──────────────┘ │  │ ┌──────────────┐ │  │ │        ▲          │ │   │
│  │ │  [OPTIONAL]   │ │ │ └──────────────┘ │  └──────────────────┘  │ │   SQL DB     │ │  │ │  Load Balancer   │ │   │
│  │ └───────────────┘ │ └──────────────────┘                        │ │  (Private    │ │  │ └───────────────────┘ │   │
│  └───────────────────┘                                             │ │   Endpoint)  │ │  │ ┌───────────────────┐ │   │
│                                                                    │ └──────────────┘ │  │ │   AKS Subnet      │ │   │
│                                                                    └──────────────────┘  │ │   [OPTIONAL]      │ │   │
│                                                                                          │ │   10.10.16.0/20   │ │   │
│                                                                                          │ └───────────────────┘ │   │
│                                                                                          └───────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌────────────────────────────────────┐
                                    │        LEGEND                      │
                                    │  ═══ VPN Tunnel                    │
                                    │  ─── VNet Peering                  │
                                    │  [OPTIONAL] = Configurable         │
                                    └────────────────────────────────────┘
```

---

## 🧪 Lab Scenarios

This landing zone supports multiple hands-on lab scenarios for learning and testing. Each scenario builds on the core infrastructure.

### Scenario 1: Hub-Spoke Network Fundamentals
**Objective**: Understand Azure networking concepts and hub-spoke topology

| Task | Skills Practiced |
|------|------------------|
| Explore VNet peering connections | Virtual network peering, traffic flow |
| Test connectivity between spokes via hub | Route tables, UDRs |
| Analyze Azure Firewall logs | Network security, logging |
| Configure custom NSG rules | Network security groups |

```bash
# Deploy minimal infrastructure
deploy_firewall         = true
deploy_vpn_gateway      = false
deploy_onprem_simulation = false
```

### Scenario 2: Load Balancing & High Availability
**Objective**: Learn Azure Load Balancer concepts and IIS web server deployment

| Task | Skills Practiced |
|------|------------------|
| Test load balancer distribution | 5-tuple hash, health probes |
| Simulate VM failure (stop a VM) | Backend pool health, failover |
| Configure custom health probes | HTTP probes, intervals |
| Access VMs via NAT rules | Inbound NAT, port mapping |

```bash
# Test load balancing
curl http://<lb_frontend_ip>  # Observe round-robin between web01-prd and web02-prd

# RDP to individual servers
mstsc /v:<lb_frontend_ip>:3389  # web01
mstsc /v:<lb_frontend_ip>:3390  # web02
```

### Scenario 3: Hybrid Connectivity (VPN)
**Objective**: Configure site-to-site VPN and hybrid networking

| Task | Skills Practiced |
|------|------------------|
| Establish VPN tunnel | IPsec, IKE configuration |
| Test on-prem to Azure connectivity | VPN troubleshooting |
| Configure BGP routing (optional) | Dynamic routing, ASN |
| Access Azure resources from "on-prem" | Hybrid network design |

```bash
# Enable hybrid scenario
deploy_vpn_gateway       = true
deploy_onprem_simulation = true
enable_bgp               = true  # Optional: Enable BGP routing
```

### Scenario 4: Azure Firewall & Security
**Objective**: Implement network security controls

| Task | Skills Practiced |
|------|------------------|
| Create application rules | FQDN filtering, web categories |
| Configure network rules | IP-based filtering, protocols |
| Set up DNAT rules | Inbound traffic, port forwarding |
| Analyze threat intelligence logs | Security monitoring |

```powershell
# From jumpbox, test firewall rules
Test-NetConnection -ComputerName google.com -Port 443
Invoke-WebRequest -Uri https://ifconfig.me  # Check SNAT IP
```

### Scenario 5: Containers with AKS
**Objective**: Deploy and manage Kubernetes workloads

| Task | Skills Practiced |
|------|------------------|
| Connect to AKS cluster | kubectl, Azure CLI |
| Deploy sample application | Kubernetes deployments |
| Configure ingress | Service exposure, networking |
| Integrate with Log Analytics | Container monitoring |

```bash
# Enable AKS
deploy_aks = true

# Connect to cluster
az aks get-credentials --resource-group rg-workload-prod-lab-east --name aks-prod-lab-east
kubectl get nodes
```

### Scenario 6: PaaS Services & Private Endpoints
**Objective**: Work with Azure PaaS services securely

| Task | Skills Practiced |
|------|------------------|
| Access Key Vault secrets | Secret management, RBAC |
| Connect to SQL via private endpoint | Private Link, DNS |
| Upload files to Storage Account | Blob storage, access tiers |
| Test Azure Functions | Serverless compute |

```powershell
# From jumpbox, access Key Vault
$secret = Get-AzKeyVaultSecret -VaultName "kv-azlab-xxxx" -Name "admin-password"

# Test SQL connectivity
Test-NetConnection -ComputerName "sql-xxxx.database.windows.net" -Port 1433
```

### Scenario 7: Monitoring & Alerting
**Objective**: Implement Azure Monitor for infrastructure

| Task | Skills Practiced |
|------|------------------|
| Review Log Analytics queries | KQL, log analysis |
| Create custom alerts | Metric alerts, action groups |
| Configure diagnostic settings | Resource logging |
| Build monitoring dashboards | Azure Dashboards, workbooks |

```kusto
// Sample KQL query for VM performance
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
| render timechart
```

### Scenario 8: Application Gateway & WAF
**Objective**: Implement Layer 7 load balancing with WAF

| Task | Skills Practiced |
|------|------------------|
| Configure backend pools | Health probes, routing |
| Test WAF rules | OWASP protection, custom rules |
| Set up URL path-based routing | Multi-site hosting |
| Analyze WAF logs | Security investigation |

```bash
# Enable Application Gateway
deploy_application_gateway = true
appgw_waf_mode             = "Detection"  # or "Prevention"
```

---

## 📊 Lab Progress Tracker

Use this checklist to track your learning progress:

- [ ] **Core Infrastructure**
  - [ ] Deployed hub-spoke topology
  - [ ] Verified VNet peering connectivity
  - [ ] Tested Azure Firewall egress
  - [ ] Accessed jumpbox via RDP/Bastion

- [ ] **Load Balancing**
  - [ ] Tested HTTP load balancing
  - [ ] Verified health probe behavior
  - [ ] Used NAT rules for RDP access
  - [ ] Stopped a VM and verified failover

- [ ] **Security**
  - [ ] Reviewed NSG rules
  - [ ] Created custom firewall rules
  - [ ] Accessed Key Vault secrets
  - [ ] Analyzed security logs

- [ ] **Hybrid Networking** (Optional)
  - [ ] Established VPN tunnel
  - [ ] Tested cross-premises connectivity
  - [ ] Configured BGP (if enabled)

- [ ] **Containers** (Optional)
  - [ ] Deployed AKS cluster
  - [ ] Connected with kubectl
  - [ ] Deployed sample workload

- [ ] **Monitoring**
  - [ ] Queried Log Analytics
  - [ ] Created custom alert
  - [ ] Built monitoring dashboard

---

## 🔄 Traffic Flow

### Network Traffic Patterns

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    TRAFFIC FLOWS                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘

  INTERNET                   INTERNET                    INTERNET
      │                          │                           │
      ▼                          ▼                           ▼
┌───────────┐            ┌───────────────┐            ┌───────────────┐
│   Azure   │            │    Public     │            │  Application  │
│ Firewall  │            │ Load Balancer │            │   Gateway     │
│  (SNAT)   │            │               │            │   (WAF)       │
└─────┬─────┘            └───────┬───────┘            └───────┬───────┘
      │                          │                           │
      ▼                          ▼                           ▼
┌───────────────┐        ┌───────────────┐            ┌───────────────┐
│ Spoke VNets   │        │  Web Servers  │            │  Web Servers  │
│ (Egress Only) │        │  (Direct LB)  │            │  (via AppGW)  │
└───────────────┘        └───────────────┘            └───────────────┘

Flow 1: Outbound         Flow 2: Inbound              Flow 3: WAF
(All Spokes)             (Load Balancer)              (App Gateway)
```

### Flow Details

| Flow | Path | Use Case |
|------|------|----------|
| **Outbound (SNAT)** | VM → Azure Firewall → Internet | All spoke VMs accessing internet |
| **Load Balancer** | Internet → Public LB → Web VMs | Direct HTTP/HTTPS to web tier |
| **App Gateway** | Internet → App GW (WAF) → Web VMs | WAF-protected web traffic |
| **Spoke-to-Spoke** | Spoke A → Hub Firewall → Spoke B | Cross-spoke communication |
| **VPN Tunnel** | On-Prem → VPN GW → Hub → Spokes | Hybrid connectivity |

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

| Resource Group | Purpose | Key Resources |
|----------------|---------|---------------|
| `rg-hub-{env}-{location}` | Hub networking | Azure Firewall, VPN Gateway, App Gateway |
| `rg-identity-{env}-{location}` | Identity services | Domain Controllers (DC01, DC02) |
| `rg-management-{env}-{location}` | Operations | Jumpbox, Log Analytics, Alerts |
| `rg-shared-{env}-{location}` | Shared services | Key Vault, Storage Account, SQL Database |
| `rg-workload-prod-{env}-{location}` | Production workload | Load Balancer, Web Servers, AKS |
| `rg-onprem-{env}-{location}` | Simulated on-prem | VPN Gateway, File Server (Optional) |

### Core Infrastructure (~130 Resources)

| Category | Resources | Count |
|----------|-----------|-------|
| **Networking** | VNets, Subnets, NSGs, Route Tables, Peerings | ~25 |
| **Security** | Azure Firewall, Firewall Policy, Rule Collections | ~8 |
| **Compute** | VMs (DC, Jumpbox, Web Servers), NICs, Disks | ~15 |
| **Load Balancing** | Load Balancer, Backend Pool, Health Probes, Rules | ~8 |
| **Storage** | Storage Account, Key Vault, File Shares | ~5 |
| **Database** | Azure SQL Server, Database, Private Endpoint | ~4 |
| **Monitoring** | Log Analytics, Diagnostic Settings, Alerts | ~20+ |
| **Identity** | Managed Identities, RBAC Assignments | ~5 |

### Load Balancer Configuration

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

### Web Servers (IIS)

| Resource | Configuration | Purpose |
|----------|---------------|---------|
| **web01-prd** | Windows Server 2022 Core, Standard_B1ms | IIS Web Server |
| **web02-prd** | Windows Server 2022 Core, Standard_B1ms | IIS Web Server |
| **IIS Extension** | CustomScriptExtension | Auto-install IIS + custom page |

### Monitoring & Alerting

| Resource | Configuration |
|----------|---------------|
| **Log Analytics Workspace** | 30-day retention, 1GB daily quota |
| **Diagnostic Settings** | Azure Firewall, VPN Gateway, App Gateway |
| **CPU Alert** | VM CPU > 80% for 5 minutes |
| **Disk Read Alert** | Disk read ops > 100/s |
| **Firewall Alert** | Throughput anomaly detection |
| **Action Group** | Email notifications |

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

## 🧪 Testing the Environment

### Access Points Summary

| Service | Access Method | Notes |
|---------|---------------|-------|
| **Web Servers (LB)** | `http://<lb_frontend_ip>` | Load balanced HTTP |
| **Web01 RDP** | `<lb_frontend_ip>:3389` | NAT rule |
| **Web02 RDP** | `<lb_frontend_ip>:3390` | NAT rule |
| **Jumpbox** | `<jumpbox_public_ip>:3389` | If public IP enabled |
| **Jumpbox (via Firewall)** | DNAT through firewall | If no public IP |
| **On-Prem Mgmt VM** | `<onprem_mgmt_vm_public_ip>:3389` | If deployed |

### Test Load Balancing

```powershell
# From your local machine - run multiple times
# You should see responses from both web01-prd and web02-prd
curl http://$(terraform output -raw lb_frontend_ip)

# Or use PowerShell
1..10 | ForEach-Object { 
    (Invoke-WebRequest -Uri "http://$(terraform output -raw lb_frontend_ip)" -UseBasicParsing).Content 
}
```

### Expected Response

```html
<h1>web01-prd</h1>
<p>Azure Landing Zone - prod Workload</p>
<p>Load Balanced Web Server</p>
```

### Test Connectivity from Jumpbox

```powershell
# RDP to jumpbox first, then test internal connectivity

# Test Domain Controller
Test-NetConnection -ComputerName 10.1.1.4 -Port 389  # LDAP

# Test Web Servers
Test-NetConnection -ComputerName 10.10.1.4 -Port 80
Test-NetConnection -ComputerName 10.10.1.5 -Port 80

# Test Key Vault
Resolve-DnsName kv-azlab-xxxx.vault.azure.net

# Test SQL via Private Endpoint
Test-NetConnection -ComputerName sql-azlab-xxxx.database.windows.net -Port 1433

# Test outbound through firewall
Invoke-WebRequest -Uri https://ifconfig.me -UseBasicParsing  # Shows firewall's public IP
```

### Test VPN Connectivity (If Deployed)

```powershell
# From on-prem management VM
Test-NetConnection -ComputerName 10.1.1.4 -Port 389   # DC in Azure
Test-NetConnection -ComputerName 10.2.1.4 -Port 3389  # Jumpbox in Azure

# From Azure jumpbox
Test-NetConnection -ComputerName 10.100.1.4 -Port 445  # File server on-prem
```

### Health Check Commands

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

# Check VPN tunnel status
az network vpn-connection show \
  --resource-group rg-hub-lab-east \
  --name vpn-conn-hub-to-onprem \
  --query "connectionStatus" -o tsv
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

### Monthly Cost by Deployment Profile

| Profile | Est. Monthly Cost | Key Cost Drivers |
|---------|-------------------|------------------|
| **Minimal** | ~$150-200 | VMs only, no firewall |
| **Standard** | ~$450-550 | Firewall ($350), VMs (~$150), LB (~$25) |
| **Standard + PaaS** | ~$500-600 | Standard + PaaS services (~$60) |
| **Full Hybrid** | ~$650-750 | Standard + VPN Gateway (~$140) |
| **Enterprise** | ~$900-1000 | Full + AKS (~$150) + App Gateway (~$36) |

### Detailed Cost Breakdown

| Resource | SKU | Monthly Cost |
|----------|-----|--------------|
| **Azure Firewall** | Standard | ~$350 |
| **VPN Gateway** | VpnGw1 | ~$140 |
| **Application Gateway** | WAF_v2 | ~$36 |
| **Public Load Balancer** | Standard | ~$25 |
| **Web Servers (2x)** | Standard_B1ms | ~$30 |
| **Domain Controller** | Standard_B2s | ~$30 |
| **Jumpbox** | Standard_B2s | ~$30 |
| **On-Prem VMs (2x)** | Standard_B2s | ~$60 |
| **AKS Cluster (1 node)** | Standard_B2s | ~$30 |
| **Storage Account** | Standard_LRS | ~$5 |
| **Key Vault** | Standard | ~$3 |
| **SQL Database** | Basic DTU | ~$5 |
| **Log Analytics** | PerGB2018 | ~$10 |

### PaaS Services (Low Cost/Free Tier)

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| **Azure Functions** | Consumption | **FREE** |
| **Static Web Apps** | Free | **FREE** |
| **Logic Apps** | Consumption | ~$0 (pay per run) |
| **Event Grid** | Standard | **FREE** (100k ops) |
| **Service Bus** | Basic | ~$0.05 |
| **App Service** | B1 Basic | ~$13 |
| **Container Apps** | Consumption | ~$5 |
| **Cosmos DB** | Serverless | ~$0-5 |
| **Total PaaS** | | **~$20-60/month** |

### 💡 Cost Optimization Tips

| Tip | Savings |
|-----|---------|
| ✅ Enable `auto_shutdown` for VMs | ~50% on VM costs |
| ✅ Use `Standard_B1ms` for web servers | Sufficient for IIS |
| ✅ Disable VPN Gateway when not testing | ~$140/month |
| ✅ Disable AKS when not using containers | ~$30-150/month |
| ✅ Use Azure Firewall Basic SKU | ~$100/month (vs Standard) |
| ✅ Set `log_daily_quota_gb = 1` | Prevents log overage |

### Auto-Shutdown Schedule

VMs are configured to auto-shutdown at **7:00 PM** local time when `enable_auto_shutdown = true` (default). This saves ~50% on compute costs for lab environments.

---

## 🔧 Troubleshooting

### Common Issues & Solutions

#### Load Balancer Not Responding

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

#### Asymmetric Routing Issues

If the load balancer is timing out:

1. **Check route table** - Web subnet should NOT route through firewall when using public LB
2. **Verify** `lb_type = "public"` in terraform.tfvars
3. **Confirm** web subnet has direct internet routing (no UDR to firewall)

#### IIS Not Installed on Web Servers

```powershell
# RDP to the VM via NAT rule
mstsc /v:<lb_frontend_ip>:3389  # web01
mstsc /v:<lb_frontend_ip>:3390  # web02

# Check IIS status
Get-WindowsFeature -Name Web-Server

# Manually install if needed
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Recreate the default page
$content = "<h1>$env:COMPUTERNAME</h1><p>Azure Landing Zone Web Server</p>"
Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value $content
```

#### VPN Tunnel Not Connecting

```bash
# Check VPN connection status
az network vpn-connection show \
  --resource-group rg-hub-lab-east \
  --name vpn-conn-hub-to-onprem \
  --query "{Status:connectionStatus,IngressBytes:ingressBytesTransferred,EgressBytes:egressBytesTransferred}" -o table

# Check VPN Gateway status
az network vnet-gateway show \
  --resource-group rg-hub-lab-east \
  --name vpngw-hub-lab-east \
  --query "provisioningState" -o tsv

# Reset VPN connection if stuck
az network vpn-connection update \
  --resource-group rg-hub-lab-east \
  --name vpn-conn-hub-to-onprem \
  --set connectionProtocol=IKEv2
```

#### Cannot Access Key Vault

```powershell
# Check network access (from jumpbox)
Test-NetConnection -ComputerName kv-azlab-xxxx.vault.azure.net -Port 443

# Verify RBAC access
az role assignment list --scope /subscriptions/<sub-id>/resourceGroups/rg-shared-lab-east

# Check Key Vault firewall
az keyvault network-rule list --name kv-azlab-xxxx
```

#### SQL Connection Failing

```powershell
# Verify private endpoint DNS resolution
Resolve-DnsName sql-azlab-xxxx.database.windows.net

# Should return private IP (10.3.x.x), not public IP

# Test connectivity
Test-NetConnection -ComputerName sql-azlab-xxxx.database.windows.net -Port 1433
```

#### Terraform Apply Errors

```bash
# State lock error
terraform force-unlock <lock-id>

# Resource already exists
terraform import <resource_address> <resource_id>

# Quota exceeded
# Request quota increase in Azure Portal or change region

# Provider version mismatch
terraform init -upgrade
```

#### Azure Firewall Blocking Traffic

```kusto
// Check firewall logs in Log Analytics
AzureDiagnostics
| where Category == "AzureFirewallNetworkRule" or Category == "AzureFirewallApplicationRule"
| where msg_s contains "Deny"
| project TimeGenerated, msg_s
| order by TimeGenerated desc
| take 50
```

### Deployment Timing Reference

| Resource | Typical Deploy Time |
|----------|---------------------|
| VNets, Subnets, NSGs | ~2-3 minutes |
| Azure Firewall | ~5-8 minutes |
| VPN Gateway | ~25-35 minutes |
| VMs (with extensions) | ~8-12 minutes |
| IIS Extension | ~3-5 minutes |
| Firewall Rule Collections | ~3 minutes each |
| AKS Cluster | ~10-15 minutes |
| Application Gateway | ~8-12 minutes |

---

## 📁 Project Structure

```
azure-landing-zone-lab/
├── main.tf                    # Root orchestration - all landing zones
├── variables.tf               # 50+ configurable input variables
├── outputs.tf                 # Key resource outputs (IPs, URLs, etc.)
├── locals.tf                  # Computed local values
├── terraform.tfvars           # Your configuration (gitignored)
├── terraform.tfvars.example   # Example configuration template
│
├── environments/              # Environment-specific configurations
│   ├── dev.tfvars             # Development settings
│   └── prod.tfvars            # Production settings
│
├── landing-zones/             # Landing zone modules (CAF aligned)
│   ├── hub/                   # Hub VNet, Firewall, VPN Gateway, App Gateway
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── identity/              # Domain Controllers, AD DS
│   ├── management/            # Jumpbox, Log Analytics, Monitoring
│   ├── shared-services/       # Key Vault, Storage, SQL Database
│   ├── workload/              # Load Balancer, Web Servers, AKS
│   └── onprem-simulated/      # Simulated on-premises environment
│
└── modules/                   # Reusable infrastructure modules
    ├── aks/                   # Azure Kubernetes Service
    ├── compute/
    │   └── windows-vm/        # Windows Server VMs
    ├── firewall/              # Azure Firewall
    ├── firewall-rules/        # Firewall policy & rule collections
    ├── keyvault/              # Azure Key Vault
    ├── monitoring/
    │   ├── action-group/      # Alert action groups
    │   ├── alerts/            # Metric alerts
    │   ├── diagnostic-settings/  # Resource diagnostics
    │   └── log-analytics/     # Log Analytics workspace
    ├── naming/                # Resource naming conventions
    ├── networking/
    │   ├── local-network-gateway/  # On-prem gateway definition
    │   ├── nsg/               # Network Security Groups
    │   ├── peering/           # VNet peering
    │   ├── route-table/       # UDR route tables
    │   ├── subnet/            # Subnet with service endpoints
    │   ├── vnet/              # Virtual Networks
    │   ├── vpn-connection/    # Site-to-site VPN
    │   └── vpn-gateway/       # VPN Gateway
    ├── private-endpoint/      # Private Link endpoints
    ├── resource-group/        # Resource group factory
    ├── sql/                   # Azure SQL Database
    └── storage/               # Storage Account
```

### Key Files

| File | Purpose |
|------|---------|
| `main.tf` | Orchestrates all landing zones and resources |
| `variables.tf` | 50+ configurable parameters for customization |
| `terraform.tfvars` | Your environment-specific values |
| `outputs.tf` | Connection info (IPs, URLs, FQDNs) |

---

## 📚 Configuration Reference

### Essential Variables

```hcl
# terraform.tfvars

# =============================================================================
# REQUIRED - Must be set
# =============================================================================
subscription_id    = "your-subscription-id"
admin_password     = "YourSecureP@ssw0rd!"    # Minimum 12 chars, complexity required
sql_admin_password = "SqlSecureP@ssw0rd!"
vpn_shared_key     = "YourVPNSharedKey123!"   # If using VPN

# =============================================================================
# CORE SETTINGS
# =============================================================================
project     = "azlab"                          # Resource naming prefix
environment = "lab"                            # Environment tag
location    = "eastus"                         # Azure region

# =============================================================================
# DEPLOYMENT FLAGS - Enable/disable components
# =============================================================================
deploy_firewall          = true                # Azure Firewall (~$350/mo)
deploy_vpn_gateway       = true                # VPN Gateway (~$140/mo)
deploy_onprem_simulation = true                # Simulated on-premises
deploy_load_balancer     = true                # Public Load Balancer
deploy_aks               = false               # Kubernetes cluster
deploy_application_gateway = false             # App Gateway with WAF

# =============================================================================
# VM CONFIGURATION
# =============================================================================
vm_size              = "Standard_B2s"          # Default VM size
lb_web_server_count  = 2                       # Number of IIS servers
lb_web_server_size   = "Standard_B1ms"         # Web server size
enable_auto_shutdown = true                    # Shutdown VMs at 7 PM

# =============================================================================
# PAAS SERVICES (All optional, most are free tier)
# =============================================================================
deploy_functions      = false                  # Azure Functions (FREE)
deploy_static_web_app = false                  # Static Web Apps (FREE)
deploy_logic_apps     = false                  # Logic Apps (pay per run)
deploy_event_grid     = false                  # Event Grid (FREE 100k)
deploy_service_bus    = false                  # Service Bus (~$0.05/mo)
deploy_app_service    = false                  # App Service (~$13/mo)
deploy_container_apps = false                  # Container Apps (~$5/mo)
deploy_cosmos_db      = false                  # Cosmos DB (serverless)
```

### Network Address Space Reference

| Network | CIDR | Subnets |
|---------|------|---------|
| **Hub** | 10.0.0.0/16 | Gateway (10.0.0.0/24), Firewall (10.0.1.0/24), Mgmt (10.0.2.0/24), AppGW (10.0.3.0/24) |
| **Identity** | 10.1.0.0/16 | DC Subnet (10.1.1.0/24) |
| **Management** | 10.2.0.0/16 | Jumpbox (10.2.1.0/24) |
| **Shared** | 10.3.0.0/16 | App (10.3.1.0/24), Private Endpoint (10.3.2.0/24) |
| **Workload Prod** | 10.10.0.0/16 | Web (10.10.1.0/24), App (10.10.2.0/24), Data (10.10.3.0/24), AKS (10.10.16.0/20) |
| **On-Premises** | 10.100.0.0/16 | Gateway (10.100.0.0/24), Servers (10.100.1.0/24) |

---

## 🚀 Quick Command Reference

```bash
# Initialize
terraform init

# Plan with specific var file
terraform plan -var-file="environments/prod.tfvars" -out=tfplan

# Apply
terraform apply tfplan

# Get outputs
terraform output

# Get specific output
terraform output lb_frontend_ip
terraform output -raw keyvault_uri

# Destroy everything
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=module.workload_prod

# Import existing resource
terraform import azurerm_resource_group.hub /subscriptions/.../resourceGroups/rg-hub-lab-east
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Microsoft Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Landing Zones](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)

---

## 📞 Support

| Resource | Link |
|----------|------|
| **Issues** | [GitHub Issues](https://github.com/Jamonygr/azure-landing-zone-lab/issues) |
| **Terraform Docs** | [AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) |
| **Azure Docs** | [Azure Documentation](https://docs.microsoft.com/azure/) |

---

**Built with ❤️ for learning Azure infrastructure**

*Last Updated: December 2025*
