# 🏗️ Azure Landing Zone Lab - Terraform

[![Terraform](https://img.shields.io/badge/Terraform->=1.9.0-623CE4?logo=terraform)](https://terraform.io)
[![Azure](https://img.shields.io/badge/Azure-AzureRM%204.x-0078D4?logo=microsoftazure)](https://azure.microsoft.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A **production-ready** Azure Landing Zone lab environment built with Terraform, following Microsoft's Cloud Adoption Framework (CAF) best practices. This project deploys a complete enterprise-grade hub-spoke network topology with identity services, security controls, and application workloads.

> 💡 **Modular Design**: Core infrastructure deploys in ~10-15 minutes. Optional components (VPN Gateway, AKS) can be enabled when needed, with VPN/OnPrem adding ~30-45 minutes to deployment time.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture Diagram](#-architecture-diagram)
- [What Gets Deployed](#-what-gets-deployed)
- [Optional Components](#-optional-components)
- [Network Topology](#-network-topology)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Configuration Options](#-configuration-options)
- [Resource Details](#-resource-details)
- [Security Features](#-security-features)
- [Cost Estimation](#-cost-estimation)
- [Learning Objectives](#-learning-objectives)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

This Terraform project creates a complete Azure Landing Zone lab environment that simulates an enterprise hybrid cloud setup. It includes:

### Core Components (Always Deployed)
- **Hub-Spoke Network Topology** - Centralized connectivity with Azure Firewall
- **Identity Services** - Windows Server Domain Controllers for Active Directory
- **Management Zone** - Jumpbox for secure access and Log Analytics for monitoring
- **Shared Services** - Azure Key Vault for secrets, Storage Account for file shares

### Optional Components (Configurable)
- **🔗 VPN Gateway & Simulated On-Premises** - Site-to-site VPN connectivity for hybrid scenarios *(adds ~30-45 min deployment time)*
- **☸️ Azure Kubernetes Service (AKS)** - Managed Kubernetes cluster for container workloads
- **🖥️ Workload VMs** - Web/App/SQL tier Windows VMs for traditional workloads
- **🗄️ Azure SQL Database** - Managed relational database with private endpoint

### Use Cases

- 🎓 **Learning** - Practice Azure networking, security, and infrastructure as code
- 🧪 **Testing** - Validate architectures before production deployment
- 📚 **Training** - Teach teams about Azure Landing Zones and CAF
- 🔬 **PoC** - Quickly spin up proof-of-concept environments

---

## ⚡ Deployment Profiles

| Profile | Components | Deployment Time | Monthly Cost |
|---------|------------|-----------------|--------------|
| **Minimal** | Core networking + VMs only | ~10 min | ~$150 |
| **Standard** | Core + Firewall (no VPN/AKS) | ~15 min | ~$450 |
| **Full Hybrid** | Everything including VPN + AKS | ~45-60 min | ~$850 |

> 🚀 **Quick Start Tip**: Start with the Standard profile (VPN and AKS disabled) for faster iteration, then enable hybrid components when ready to test VPN scenarios.

---

## 🏛️ Architecture Diagram

```
                              ┌─────────────────────────────────────────────────────────────────────────┐
                              │                        AZURE CLOUD                                      │
                              │                                                                         │
┌─────────────────┐           │  ┌───────────────────────────────────────────────────────────────────┐ │
│   ON-PREMISES   │           │  │                      HUB VNET (10.0.0.0/16)                       │ │
│   (Simulated)   │           │  │                                                                   │ │
│   [OPTIONAL]    │           │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐   │ │
│                 │           │  │  │   Gateway   │  │   Firewall  │  │     Management Subnet   │   │ │
│  ┌───────────┐  │   VPN     │  │  │   Subnet    │  │    Subnet   │  │      (10.0.2.0/24)      │   │ │
│  │ File      │  │  Tunnel   │  │  │ 10.0.0.0/24 │  │ 10.0.1.0/24 │  └─────────────────────────┘   │ │
│  │ Server    │◄─┼───────────┼──┼──┤ [OPTIONAL]  │  │             │                                │ │
│  │10.100.1.4 │  │           │  │  │             │  │ ┌─────────┐ │                                │ │
│  └───────────┘  │           │  │  │ ┌─────────┐ │  │ │Azure FW │ │                                │ │
│                 │           │  │  │ │VPN GW   │ │  │ │(Std)    │ │                                │ │
│  VNet:          │           │  │  │ │(VpnGw1) │ │  │ └─────────┘ │                                │ │
│  10.100.0.0/16  │           │  │  │ └─────────┘ │  └─────────────┘                                │ │
└─────────────────┘           │  │  └─────────────┘                                                  │ │
                              │  └───────────────────────────────────────────────────────────────────┘ │
                              │              │                    │                                     │
                              │              │    VNet Peerings   │                                     │
                              │    ┌─────────┴────────────────────┴───────────┐                        │
                              │    │                      │                    │                        │
                              │    ▼                      ▼                    ▼                        │
                              │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │
                              │  │  IDENTITY    │  │  MANAGEMENT  │  │   SHARED     │                  │
                              │  │   VNET       │  │    VNET      │  │  SERVICES    │                  │
                              │  │10.1.0.0/16   │  │10.2.0.0/16   │  │10.3.0.0/16   │                  │
                              │  │              │  │              │  │              │                  │
                              │  │ ┌──────────┐ │  │ ┌──────────┐ │  │ ┌──────────┐ │                  │
                              │  │ │  DC01    │ │  │ │ Jumpbox  │ │  │ │Key Vault │ │                  │
                              │  │ │ (Win22)  │ │  │ │ (Win22)  │ │  │ │          │ │                  │
                              │  │ │10.1.1.4  │ │  │ │10.2.1.4  │ │  │ └──────────┘ │                  │
                              │  │ └──────────┘ │  │ └──────────┘ │  │ ┌──────────┐ │                  │
                              │  │ ┌──────────┐ │  │ ┌──────────┐ │  │ │ Storage  │ │                  │
                              │  │ │  DC02    │ │  │ │   Log    │ │  │ │ Account  │ │                  │
                              │  │ │[Optional]│ │  │ │Analytics │ │  │ │          │ │                  │
                              │  │ │10.1.1.5  │ │  │ └──────────┘ │  │ └──────────┘ │                  │
                              │  │ └──────────┘ │  └──────────────┘  └──────────────┘                  │
                              │  └──────────────┘                                                       │
                              │                                                                         │
                              │              │                                                          │
                              │              ▼                                                          │
                              │  ┌───────────────────────────────────────────────────────────────────┐ │
                              │  │                 WORKLOAD PROD VNET (10.10.0.0/16)                 │ │
                              │  │                                                                   │ │
                              │  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐   │ │
                              │  │  │   Web Subnet    │  │   App Subnet    │  │  Data Subnet    │   │ │
                              │  │  │  10.10.1.0/24   │  │  10.10.2.0/24   │  │  10.10.3.0/24   │   │ │
                              │  │  │   [OPTIONAL]    │  │   [OPTIONAL]    │  │   [OPTIONAL]    │   │ │
                              │  │  │  ┌───────────┐  │  │  ┌───────────┐  │  │  ┌───────────┐  │   │ │
                              │  │  │  │  Web VM   │  │  │  │  App VM   │  │  │  │  SQL VM   │  │   │ │
                              │  │  │  │ (Win22)   │  │  │  │ (Win22)   │  │  │  │ (Win22)   │  │   │ │
                              │  │  │  │10.10.1.4  │  │  │  │10.10.2.4  │  │  │  │10.10.3.4  │  │   │ │
                              │  │  │  └───────────┘  │  │  └───────────┘  │  │  └───────────┘  │   │ │
                              │  │  └─────────────────┘  └─────────────────┘  └─────────────────┘   │ │
                              │  │                                                                   │ │
                              │  │  ┌─────────────────────────────────────────────────────────────┐ │ │
                              │  │  │              AKS Subnet (10.10.64.0/18) [OPTIONAL]           │ │ │
                              │  │  │                                                              │ │ │
                              │  │  │   ┌──────────────────────────────────────────────────────┐  │ │ │
                              │  │  │   │      Azure Kubernetes Service (AKS)                  │  │ │ │
                              │  │  │   │      - 1 Node (Standard_B2ms)                        │  │ │ │
                              │  │  │   │      - Kubernetes 1.29+                              │  │ │ │
                              │  │  │   │      - Azure CNI Networking                          │  │ │ │
                              │  │  │   └──────────────────────────────────────────────────────┘  │ │ │
                              │  │  └─────────────────────────────────────────────────────────────┘ │ │
                              │  │                                                                   │ │
                              │  │  ┌─────────────────────────────────────────────────────────────┐ │ │
                              │  │  │                Azure SQL Database [OPTIONAL]                 │ │ │
                              │  │  │   - Basic SKU (2GB)                                          │ │ │
                              │  │  │   - Private Endpoint                                         │ │ │
                              │  │  └─────────────────────────────────────────────────────────────┘ │ │
                              │  └───────────────────────────────────────────────────────────────────┘ │
                              └─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Optional Components

### VPN Gateway & Simulated On-Premises

The VPN components simulate a hybrid cloud scenario with site-to-site connectivity:

| Component | Purpose | Deployment Time |
|-----------|---------|-----------------|
| VPN Gateway (Hub) | Azure-side VPN endpoint | ~25-30 min |
| VPN Gateway (OnPrem) | Simulated on-prem endpoint | ~25-30 min |
| Local Network Gateway | On-prem network definition | ~1 min |
| VPN Connection | Encrypted IPsec tunnel | ~2 min |
| File Server VM | Simulated on-prem workload | ~2 min |

**Enable with:**
```hcl
deploy_vpn_gateway       = true   # Hub VPN Gateway
deploy_onprem_simulation = true   # On-prem VNet, VPN GW, and VMs
enable_bgp               = false  # Optional BGP routing
```

> ⚠️ **Note**: VPN Gateways take 25-45 minutes to provision. Disable for faster development cycles.

### Azure Kubernetes Service (AKS)

Deploy a managed Kubernetes cluster for container workloads:

| Feature | Configuration |
|---------|--------------|
| Node Pool | 1x Standard_B2ms (scalable) |
| Networking | Azure CNI with custom VNet integration |
| Subnet | 10.10.64.0/18 (16,382 IPs for pods) |
| Version | Kubernetes 1.29+ |

**Enable with:**
```hcl
deploy_aks = true
```

### Workload VMs

Traditional 3-tier Windows VM architecture:

| VM | Subnet | IP | Purpose |
|----|--------|-------|---------|
| Web VM | 10.10.1.0/24 | 10.10.1.4 | Web tier (IIS) |
| App VM | 10.10.2.0/24 | 10.10.2.4 | Application tier |
| SQL VM | 10.10.3.0/24 | 10.10.3.4 | Database tier |

**Enable with:**
```hcl
deploy_workload_vms = true
```

---

## 📦 What Gets Deployed

### Resource Groups (5-6 total)

| Resource Group | Purpose | Optional |
|----------------|---------|----------|
| `rg-hub-{env}-{location}` | Hub networking resources | No |
| `rg-identity-{env}-{location}` | Domain Controllers | No |
| `rg-management-{env}-{location}` | Jumpbox & Monitoring | No |
| `rg-shared-{env}-{location}` | Key Vault & Storage | No |
| `rg-workload-prod-{env}-{location}` | Production workloads | No |
| `rg-onprem-{env}-{location}` | Simulated on-premises | **Yes** |

### Complete Resource Inventory

#### 🌐 Networking Resources

| Resource | Count | Description |
|----------|-------|-------------|
| Virtual Networks | 6 | Hub, Identity, Management, Shared, Workload, OnPrem |
| Subnets | 12+ | Gateway, Firewall, Management, DC, Jumpbox, AKS, Web, App, Data, etc. |
| VNet Peerings | 8-10 | Hub-to-spoke connectivity (bidirectional) |
| Network Security Groups | 6+ | Subnet-level firewall rules |
| Route Tables | 5 | Custom routing through Azure Firewall |
| Public IP Addresses | 1-3 | Azure Firewall (1), VPN Gateway (2 if enabled) |

#### 🔥 Security Resources

| Resource | Description | Optional |
|----------|-------------|----------|
| Azure Firewall | Centralized egress filtering with policy rules | No |
| Firewall Policy | Network and application rule collections | No |
| VPN Gateway (Hub) | Site-to-site VPN to simulated on-premises | **Yes** |
| VPN Gateway (OnPrem) | Simulated on-premises VPN endpoint | **Yes** |
| VPN Connection | Encrypted tunnel between Hub and OnPrem | **Yes** |
| Key Vault | Secure storage for secrets and certificates | No |

#### 💻 Compute Resources

| Resource | Subnet | IP Address | Purpose | Optional |
|----------|--------|------------|---------|----------|
| DC01 (Windows Server 2022) | Identity | 10.1.1.4 | Primary Domain Controller | No |
| DC02 (Windows Server 2022) | Identity | 10.1.1.5 | Secondary DC | **Yes** |
| Jumpbox (Windows Server 2022) | Management | 10.2.1.4 | Secure access point | No |
| Web VM (Windows Server 2022) | Workload-Web | 10.10.1.4 | Web tier | **Yes** |
| App VM (Windows Server 2022) | Workload-App | 10.10.2.4 | Application tier | **Yes** |
| SQL VM (Windows Server 2022) | Workload-Data | 10.10.3.4 | Database tier | **Yes** |
| FileServer (Windows Server 2022) | OnPrem | 10.100.1.4 | Simulated on-prem file server | **Yes** |

#### ☸️ Platform Services

| Resource | SKU | Description | Optional |
|----------|-----|-------------|----------|
| Azure Kubernetes Service | Standard_B2ms (1 node) | Managed Kubernetes cluster | **Yes** |
| Azure SQL Database | Basic (2GB) | Managed relational database | **Yes** |
| Log Analytics Workspace | PerGB2018 | Centralized logging | No |
| Storage Account | Standard_LRS | Blob containers and file shares | No |

---

## 🌐 Network Topology

### Address Space Allocation

| Network | CIDR | Usable IPs | Purpose |
|---------|------|------------|---------|
| **Hub** | 10.0.0.0/16 | 65,534 | Central connectivity hub |
| ├─ GatewaySubnet | 10.0.0.0/24 | 251 | VPN Gateway |
| ├─ AzureFirewallSubnet | 10.0.1.0/24 | 251 | Azure Firewall |
| └─ ManagementSubnet | 10.0.2.0/24 | 251 | Hub management |
| **Identity** | 10.1.0.0/16 | 65,534 | Domain Controllers |
| └─ DCSubnet | 10.1.1.0/24 | 251 | DC01, DC02 |
| **Management** | 10.2.0.0/16 | 65,534 | Operations |
| └─ JumpboxSubnet | 10.2.1.0/24 | 251 | Jumpbox VM |
| **Shared** | 10.3.0.0/16 | 65,534 | Shared services |
| └─ PrivateEndpointSubnet | 10.3.1.0/24 | 251 | Private endpoints |
| **Workload Prod** | 10.10.0.0/16 | 65,534 | Production apps |
| ├─ WebSubnet | 10.10.1.0/24 | 251 | Web tier VMs |
| ├─ AppSubnet | 10.10.2.0/24 | 251 | App tier VMs |
| ├─ DataSubnet | 10.10.3.0/24 | 251 | Database VMs |
| └─ AKSSubnet | 10.10.64.0/18 | 16,382 | AKS node pool |
| **On-Premises** | 10.100.0.0/16 | 65,534 | Simulated on-prem |
| └─ ServerSubnet | 10.100.1.0/24 | 251 | File server |
| **VPN Clients** | 172.16.0.0/24 | 251 | Point-to-Site VPN |

### Network Flow

```
Internet → Azure Firewall (10.0.1.4) → Spoke VNets → Workloads
                    ↓
On-Premises ← VPN Gateway (Hub) ←→ VPN Gateway (OnPrem)
```

---

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://terraform.io/downloads) >= 1.9.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) >= 2.50.0
- Azure Subscription with **Owner** or **Contributor** access
- At least **40 vCPU quota** in your target region

### Step 1: Clone & Configure

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/azure-landing-zone-lab.git
cd azure-landing-zone-lab

# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
code terraform.tfvars
```

**Required variables in `terraform.tfvars`:**

```hcl
# Azure Configuration
subscription_id = "your-subscription-id-here"
location        = "westus"           # or your preferred region

# Authentication (use strong passwords!)
admin_password     = "YourSecurePassword123!"
sql_admin_password = "SqlSecurePassword456!"
```

### Step 2: Authenticate to Azure

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify
az account show
```

### Step 3: Deploy

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy STANDARD profile (recommended - ~15 min, no VPN/AKS)
terraform apply

# OR Deploy FULL profile with VPN and AKS (~45-60 min)
terraform apply -var="deploy_vpn_gateway=true" -var="deploy_aks=true" -var="deploy_onprem_simulation=true"
```

> ⏱️ **Deployment Times**: Standard ~15 min | With AKS ~20 min | Full Hybrid ~45-60 min

### Step 4: Access Your Environment

After deployment, use the outputs to access resources:

```bash
# View all outputs
terraform output

# Get specific values
terraform output jumpbox_private_ip
terraform output hub_vpn_gateway_public_ip
```

### Step 5: Clean Up

```bash
# Destroy all resources
terraform destroy

# Confirm with "yes"
```

---

## 📁 Project Structure

```
├── main.tf                          # Root module - orchestrates all resources
├── variables.tf                     # Input variable definitions
├── outputs.tf                       # Output value definitions
├── locals.tf                        # Local values, naming, common tags
├── terraform.tfvars                 # Your configuration (git-ignored)
├── terraform.tfvars.example         # Example configuration template
│
├── landing-zones/                   # Landing zone modules
│   ├── hub/                         # Hub network with firewall & VPN
│   │   ├── main.tf                  #   VNet, Subnets, Firewall, VPN Gateway
│   │   ├── variables.tf             #   Input variables
│   │   └── outputs.tf               #   Output values
│   │
│   ├── identity/                    # Identity services
│   │   ├── main.tf                  #   DC01, DC02 Windows VMs
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── management/                  # Management zone
│   │   ├── main.tf                  #   Jumpbox VM, Log Analytics
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── shared-services/             # Shared services
│   │   ├── main.tf                  #   Key Vault, Storage Account
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── workload/                    # Application workloads
│   │   ├── main.tf                  #   AKS, VMs, SQL Database
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── onprem-simulated/            # Simulated on-premises
│       ├── main.tf                  #   VPN Gateway, File Server
│       ├── variables.tf
│       └── outputs.tf
│
├── modules/                         # Reusable infrastructure modules
│   ├── aks/                         # Azure Kubernetes Service
│   ├── compute/windows-vm/          # Windows Virtual Machine
│   ├── firewall/                    # Azure Firewall + Policy
│   ├── firewall-rules/              # Firewall rule collections
│   ├── keyvault/                    # Azure Key Vault
│   ├── monitoring/log-analytics/    # Log Analytics Workspace
│   ├── naming/                      # CAF naming convention
│   ├── networking/
│   │   ├── vnet/                    # Virtual Network
│   │   ├── subnet/                  # Subnet
│   │   ├── nsg/                     # Network Security Group
│   │   ├── peering/                 # VNet Peering
│   │   ├── route-table/             # Route Table
│   │   ├── vpn-gateway/             # VPN Gateway
│   │   └── vpn-connection/          # VPN Connection
│   ├── private-endpoint/            # Private Endpoint
│   ├── resource-group/              # Resource Group
│   ├── sql/                         # Azure SQL Database
│   └── storage/                     # Storage Account
│
├── environments/                    # Environment-specific configs
│   ├── dev.tfvars                   # Development settings
│   └── prod.tfvars                  # Production settings
│
└── pipelines/                       # Azure DevOps CI/CD
    ├── azure-pipelines-main.yml     # Main deployment pipeline
    ├── azure-pipelines-destroy.yml  # Destroy pipeline
    ├── azure-pipelines-drift.yml    # Drift detection
    └── templates/                   # Pipeline templates
        ├── terraform-init.yml
        ├── terraform-plan.yml
        ├── terraform-apply.yml
        ├── terraform-validate.yml
        ├── security-scan.yml
        ├── cost-estimation.yml
        └── notifications.yml
```

---

## ⚙️ Configuration Options

### Feature Toggles

Toggle features on/off to control costs and deployment time:

| Feature | Variable | Default | Description | Deploy Time Impact |
|---------|----------|---------|-------------|-------------------|
| Azure Firewall | `deploy_firewall` | `true` | Central egress filtering | +4-5 min |
| **VPN Gateway** | `deploy_vpn_gateway` | `false` | Hybrid connectivity | **+25-30 min** |
| **AKS Cluster** | `deploy_aks` | `false` | Managed Kubernetes | +5-10 min |
| **On-Prem Simulation** | `deploy_onprem_simulation` | `false` | VPN-connected on-prem | **+30-40 min** |
| Secondary DC | `deploy_secondary_dc` | `false` | High availability DC | +2 min |
| Workload VMs | `deploy_workload_vms` | `true` | Web/App/SQL VMs | +3-5 min |
| Key Vault | `deploy_keyvault` | `true` | Secrets management | +1 min |
| Storage Account | `deploy_storage` | `true` | Blob & file storage | +1 min |
| SQL Database | `deploy_sql` | `true` | Managed SQL database | +2 min |

> 💡 **Recommended for Development**: Keep `deploy_vpn_gateway`, `deploy_aks`, and `deploy_onprem_simulation` as `false` for faster iteration (~15 min deploy). Enable when testing hybrid scenarios.

### Using Different Environments

```bash
# Deploy development environment (fast iteration, no VPN/AKS)
terraform apply -var-file="environments/dev.tfvars"

# Deploy production environment (full deployment)
terraform apply -var-file="environments/prod.tfvars"

# Quick deploy with VPN/AKS disabled
terraform apply -var="deploy_vpn_gateway=false" -var="deploy_aks=false" -var="deploy_onprem_simulation=false"

# Enable hybrid scenario (VPN + OnPrem simulation)
terraform apply -var="deploy_vpn_gateway=true" -var="deploy_onprem_simulation=true"
```

---

## 💰 Cost Estimation

### Monthly Cost Breakdown (USD)

| Resource | Configuration | Est. Monthly Cost | Optional |
|----------|--------------|-------------------|----------|
| Azure Firewall | Standard SKU | ~$912 | No |
| VPN Gateway (Hub) | VpnGw1 | ~$140 | **Yes** |
| VPN Gateway (OnPrem) | VpnGw1 | ~$140 | **Yes** |
| AKS Cluster | 1x Standard_B2ms | ~$70 | **Yes** |
| Windows VMs (2-6x) | Standard_B2ms | ~$60-180 | Partial |
| Azure SQL Database | Basic 2GB | ~$5 | **Yes** |
| Key Vault | Standard | ~$0.03/10K ops | No |
| Storage Account | LRS | ~$2 | No |
| Log Analytics | Per GB | ~$2.50/GB | No |
| Public IPs | 1-3x Standard | ~$3-10 | Partial |

### Cost Profiles

| Profile | Resources | Est. Monthly Cost | Deploy Time |
|---------|-----------|-------------------|-------------|
| **Minimal** | Core VNets + DC + Jumpbox (no FW) | ~$100 | ~5 min |
| **Standard** | Core + Firewall (no VPN/AKS) | ~$450 | ~15 min |
| **With AKS** | Standard + AKS Cluster | ~$520 | ~20 min |
| **Full Hybrid** | Everything (VPN + AKS + OnPrem) | ~$850 | ~45-60 min |

### Cost Saving Tips

1. **Use auto-shutdown** - VMs shut down at 7 PM (configurable)
2. **Disable VPN Gateways** - Save ~$280/month by setting `deploy_vpn_gateway = false` and `deploy_onprem_simulation = false`
3. **Disable AKS** - Save ~$70/month by setting `deploy_aks = false`
4. **Disable Azure Firewall** - Save ~$300/month (use NSGs instead) - not recommended for production learning
5. **Scale down AKS** - Use 1 node for learning
6. **Destroy when not using** - `terraform destroy`
7. **Start minimal** - Deploy core components first, enable VPN/AKS when needed

---

## 🔒 Security Features

### Network Security

- ✅ **NSGs on all subnets** - Deny-by-default with explicit allow rules
- ✅ **Azure Firewall** - Centralized egress filtering
- ✅ **Route Tables** - Force traffic through firewall
- ✅ **VNet Peering** - Isolated spoke networks
- ✅ **Private Endpoints** - No public exposure for PaaS

### Identity & Access

- ✅ **Key Vault with RBAC** - Secrets stored securely
- ✅ **Managed Identities** - No credentials in code
- ✅ **Strong passwords required** - Minimum complexity enforced

### Compute Security

- ✅ **No public IPs on VMs** - Access via Jumpbox/VPN only
- ✅ **Auto-shutdown** - VMs stop at 7 PM to reduce exposure
- ✅ **Windows Server 2022** - Latest security patches
- ✅ **TLS 1.2 minimum** - Modern encryption

### Monitoring

- ✅ **Log Analytics** - Centralized logging
- ✅ **Diagnostic settings** - Firewall logs, NSG flow logs
- ✅ **Activity Log** - Audit trail

---

## 📚 Learning Objectives

This lab helps you master:

### Networking
- 🌐 **Hub-Spoke Topology** - Enterprise network design pattern
- 🔀 **VNet Peering** - Connect virtual networks
- 🛣️ **User-Defined Routes** - Custom traffic routing
- 🔒 **NSG Rules** - Subnet-level firewalls

### Security
- 🔥 **Azure Firewall** - Centralized egress control
- 🔐 **VPN Gateway** - Site-to-site connectivity
- 🔑 **Key Vault** - Secrets and certificate management
- 🔗 **Private Endpoints** - Secure PaaS connectivity

### Compute
- 🖥️ **Windows VMs** - IaaS workloads
- ☸️ **AKS** - Managed Kubernetes
- 🗄️ **Azure SQL** - Managed databases

### DevOps
- 📜 **Terraform Modules** - Reusable infrastructure
- 🏗️ **CAF Naming** - Enterprise naming conventions
- 🚀 **Azure Pipelines** - CI/CD automation

---

## 🔑 Lab Credentials

> ⚠️ **For lab use only!** Change these immediately in production environments.

| Resource | Username | Password |
|----------|----------|----------|
| All Windows VMs | `azureadmin` | `P@ssw0rd123!Lab` |
| Azure SQL Database | `sqladmin` | `P@ssw0rd123!Lab` |

---

## 🧪 Lab Exercises

### Exercise 1: Verify Site-to-Site VPN Connectivity

**Objective:** Confirm the VPN tunnel between Hub and simulated On-Premises is working.

**Steps:**

1. **Check VPN Gateway Status in Azure Portal:**
   ```
   Portal → Virtual Network Gateways → vpng-hub-lab-east → Connections
   Status should show "Connected"
   ```

2. **RDP to On-Prem VM (has public IP):**
   ```powershell
   # Get the on-prem VM public IP from Terraform output
   terraform output onprem_vm_public_ip
   
   # RDP to on-prem management VM
   mstsc /v:<onprem_public_ip>
   # Login: azureadmin / P@ssw0rd123!Lab
   ```

3. **From On-Prem VM, ping resources across the VPN:**
   ```powershell
   # Ping the Domain Controller in Identity VNet
   ping 10.1.1.4
   
   # Ping the Jumpbox in Management VNet
   ping 10.2.1.4
   
   # Ping a workload VM
   ping 10.10.1.4
   ```

4. **Trace the route to verify VPN path:**
   ```powershell
   tracert 10.1.1.4
   # Should show traffic going through VPN gateway
   ```

**Expected Result:** All pings succeed, proving the S2S VPN is routing traffic correctly.

---

### Exercise 2: Test Azure Firewall Traffic Filtering

**Objective:** Understand how Azure Firewall controls egress traffic from spoke VNets.

**Steps:**

1. **RDP to On-Prem VM, then RDP to Jumpbox:**
   ```powershell
   # From On-Prem VM, connect to Jumpbox
   mstsc /v:10.2.1.4
   # Login: azureadmin / P@ssw0rd123!Lab
   ```

2. **From Jumpbox, test internet access:**
   ```powershell
   # Test allowed domains (should work based on firewall rules)
   Invoke-WebRequest -Uri "https://www.microsoft.com" -UseBasicParsing
   
   # Check your outbound public IP (should be the Firewall's public IP)
   Invoke-RestMethod -Uri "https://ifconfig.me/ip"
   ```

3. **View Firewall Logs in Log Analytics:**
   ```kusto
   // In Log Analytics, run this query:
   AzureDiagnostics
   | where Category == "AzureFirewallNetworkRule" or Category == "AzureFirewallApplicationRule"
   | project TimeGenerated, msg_s
   | order by TimeGenerated desc
   | take 50
   ```

4. **Check Route Tables:**
   ```
   Portal → Route Tables → rt-spoke-to-hub
   Verify 0.0.0.0/0 routes to Azure Firewall private IP (10.0.1.4)
   ```

**Expected Result:** Outbound traffic shows Firewall's public IP, logs show traffic flow.

---

### Exercise 3: Explore Hub-Spoke Connectivity

**Objective:** Verify VNet peering and understand traffic flow between spokes.

**Steps:**

1. **From Jumpbox (10.2.1.4), test connectivity to all spokes:**
   ```powershell
   # Identity VNet - Domain Controller
   Test-NetConnection -ComputerName 10.1.1.4 -Port 3389
   
   # Workload VNet - Web VM
   Test-NetConnection -ComputerName 10.10.1.4 -Port 3389
   
   # Workload VNet - App VM
   Test-NetConnection -ComputerName 10.10.2.4 -Port 3389
   
   # Workload VNet - Data VM
   Test-NetConnection -ComputerName 10.10.3.4 -Port 3389
   ```

2. **Verify peering status:**
   ```
   Portal → Virtual Networks → vnet-hub-lab-east → Peerings
   All peerings should show "Connected" status
   ```

3. **Test DNS resolution (if configured):**
   ```powershell
   nslookup dc01.lab.local 10.1.1.4
   ```

**Expected Result:** All spoke VMs reachable from Jumpbox through Hub peering.

---

### Exercise 4: Access AKS Cluster

**Objective:** Connect to the AKS cluster and deploy a sample application.

**Steps:**

1. **Get AKS credentials (from your local machine with az cli):**
   ```powershell
   # Get credentials
   az aks get-credentials --resource-group rg-workload-prod-lab-east --name aks-prod-lab-east
   
   # Verify connection
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

2. **Deploy a sample nginx application:**
   ```powershell
   kubectl create deployment nginx --image=nginx
   kubectl expose deployment nginx --port=80 --type=ClusterIP
   kubectl get services
   ```

3. **Check AKS networking:**
   ```powershell
   # View pod IPs (should be in 10.10.64.0/18 range)
   kubectl get pods -o wide
   ```

**Expected Result:** AKS cluster accessible, pods running with IPs from the AKS subnet.

---

### Exercise 5: Key Vault Secret Management

**Objective:** Store and retrieve secrets from Azure Key Vault.

**Steps:**

1. **Add a secret to Key Vault:**
   ```powershell
   # Get Key Vault name from Terraform output
   $kvName = terraform output -raw keyvault_name
   
   # Add a secret
   az keyvault secret set --vault-name $kvName --name "DatabasePassword" --value "SuperSecret123!"
   ```

2. **Retrieve the secret:**
   ```powershell
   az keyvault secret show --vault-name $kvName --name "DatabasePassword" --query value -o tsv
   ```

3. **View in Portal:**
   ```
   Portal → Key Vaults → kv-shared-lab-* → Secrets
   ```

**Expected Result:** Secret stored and retrievable via CLI and Portal.

---

### Exercise 6: Test Private Endpoints

**Objective:** Verify that PaaS services are only accessible via private endpoints.

**Steps:**

1. **Check Private Endpoint DNS:**
   ```powershell
   # From Jumpbox, resolve the SQL server FQDN
   nslookup sql-workload-prod-lab-*.database.windows.net
   # Should resolve to private IP (10.3.1.x range)
   ```

2. **Verify Private DNS Zone:**
   ```
   Portal → Private DNS Zones → privatelink.database.windows.net
   Check A record points to private IP
   ```

3. **Test SQL connectivity from Jumpbox:**
   ```powershell
   # Install SQL Server Management Studio or use sqlcmd
   Test-NetConnection -ComputerName sql-workload-prod-lab-east.database.windows.net -Port 1433
   ```

**Expected Result:** PaaS services resolve to private IPs, no public exposure.

---

### Exercise 7: Simulate Failover Scenarios

**Objective:** Test network resilience by simulating failures.

**Steps:**

1. **Test VPN Gateway failover:**
   ```powershell
   # From Azure Portal, reset the VPN Gateway
   Portal → Virtual Network Gateways → vpng-hub-lab-east → Reset
   
   # Monitor connectivity during reset (from On-Prem VM)
   ping 10.1.1.4 -t
   ```

2. **Test spoke isolation:**
   ```powershell
   # Temporarily disable a peering
   Portal → Virtual Networks → vnet-hub-lab-east → Peerings → Disable
   
   # Test connectivity (should fail)
   # Re-enable peering
   ```

3. **Test Azure Firewall rule changes:**
   ```powershell
   # Add a deny rule and test impact
   # Remove/modify and verify restoration
   ```

**Expected Result:** Understand recovery times and failure behaviors.

---

### Exercise 8: Monitor and Alerting

**Objective:** Set up monitoring dashboards and alerts.

**Steps:**

1. **Query Log Analytics:**
   ```kusto
   // Heartbeat from VMs
   Heartbeat
   | summarize LastHeartbeat = max(TimeGenerated) by Computer
   | order by LastHeartbeat desc
   
   // Performance data
   Perf
   | where ObjectName == "Processor" and CounterName == "% Processor Time"
   | summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
   ```

2. **Create a Dashboard:**
   ```
   Portal → Dashboard → New Dashboard
   Add tiles for: VM Status, Network Traffic, Firewall Logs
   ```

3. **Set up an Alert:**
   ```
   Portal → Monitor → Alerts → Create Alert Rule
   Signal: Virtual Machine Unavailable
   Action: Email notification
   ```

**Expected Result:** Visibility into environment health and proactive alerting.

---

## 🔧 Troubleshooting

### Common Issues

**1. Quota exceeded error**
```
Error: creating Virtual Machine: compute.VirtualMachinesClient#CreateOrUpdate: Failure
```
**Solution:** Request quota increase in Azure Portal → Subscriptions → Usage + quotas

**2. VPN Gateway takes too long**
```
Still creating... [45m elapsed]
```
**Solution:** VPN Gateways take 30-45 minutes. This is normal.

**3. Firewall subnet error**
```
Error: AzureFirewallSubnet must be /26 or larger
```
**Solution:** Ensure `hub_firewall_subnet_prefix` is at least /26

**4. State lock error**
```
Error: Error locking state
```
**Solution:** Wait for other operations to complete, or force unlock:
```bash
terraform force-unlock LOCK_ID
```

**5. Authentication error**
```
Error: Error building AzureRM Client
```
**Solution:** Re-authenticate:
```bash
az logout
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Disclaimer

This is a **lab environment** designed for learning and testing purposes. Before using any components in production:

- Review and harden security configurations
- Implement proper backup strategies
- Configure high availability where needed
- Follow your organization's compliance requirements

---

## 📞 Support

- 📖 [Azure Documentation](https://docs.microsoft.com/azure/)
- 📘 [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- 🏛️ [Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)

---

**Made with ❤️ for Azure learners**
