# Lab testing guide

Use this checklist after a deploy to prove the lab works end to end and to see how each landing zone connects. Follow the steps in order; every step explains what you are validating and what success looks like.

## What you will learn

- A recommended config that lights up the main scenarios without guessing feature flags.
- The order of checks that confirm hub, identity, management, shared services, workload, and hybrid connectivity all function.
- Copy/paste commands from your terminal or jumpbox, plus what to expect from each.

## Recommended lab settings for testing

Add (or confirm) these flags in `terraform.tfvars` so the tests have something to hit. Turn features off again when you want to save cost.

```hcl
deploy_firewall           = true
deploy_vpn_gateway        = true
deploy_onprem_simulation  = true
deploy_workload_prod      = true
deploy_load_balancer      = true   # Needed for web tests/NAT RDP
enable_jumpbox_public_ip  = true   # Or connect through the VPN client
deploy_log_analytics      = true
deploy_secondary_dc       = false  # Optional; keep false to shorten deploy time
```

## Test flow at a glance

| Step | Goal | Commands (examples) |
|------|------|---------------------|
| 1. Preflight | Make sure the plan is clean | `terraform fmt -check`, `terraform validate`, `terraform plan -out=tfplan` |
| 2. Deploy + outputs | Apply and gather the connection map | `terraform apply tfplan`, `terraform output connection_info` |
| 3. Hub + routing | Verify forced tunneling via firewall | `Invoke-WebRequest https://ifconfig.me` from jumpbox |
| 4. Identity VNet | Confirm the identity VM answers on its IPs | `Test-NetConnection $dc -Port 3389` |
| 5. Management entry | Reach the jumpbox and traverse spokes | RDP to `jumpbox_public_ip` or via VPN |
| 6. Shared services | Test Key Vault/Storage/SQL reachability | `Invoke-WebRequest $(terraform output -raw keyvault_uri)` |
| 7. Workload + LB | Hit the IIS sample and NAT RDP | `Invoke-WebRequest http://$LB_IP` |
| 8. VPN + on-prem | Prove the tunnel works both ways | `Test-NetConnection 10.2.1.4 -Port 3389` from on-prem VM |
| 9. Observability | Spot-check Log Analytics/diagnostics | `az monitor log-analytics workspace show --ids $(terraform output -raw log_analytics_workspace_id)` |
| 10. Clean up | Tear down when you are done | `terraform destroy` |

## Step-by-step checklist

### 1) Preflight and deploy

- Run the basics before you spend time deploying:
  ```powershell
  terraform fmt -check
  terraform validate
  terraform plan -var-file="terraform.tfvars" -out=tfplan
  terraform apply tfplan
  ```
- If you use `environments/*.tfvars`, swap the filename in `-var-file`.

### 2) Capture key outputs

- Print the connection map:
  ```powershell
  terraform output connection_info
  ```
- Save the individual values you will use in the next steps (skip any that are null because the feature is off):
  ```powershell
  $fwPrivate = terraform output -raw hub_firewall_private_ip
  $fwPublic  = terraform output -raw hub_firewall_public_ip
  $vpnIp     = terraform output -raw hub_vpn_gateway_public_ip
  $jumpPriv  = terraform output -raw jumpbox_private_ip
  $jumpPub   = terraform output -raw jumpbox_public_ip
  $dcIps     = terraform output -json domain_controller_ips | ConvertFrom-Json
  $lbIp      = terraform output -raw lb_frontend_ip          # only if deploy_load_balancer = true
  $onpremPub = terraform output -raw onprem_mgmt_vm_public_ip # only if deploy_onprem_simulation = true
  ```

### 3) Enter via the jumpbox

- RDP to `$jumpPub` (or over the VPN client pool if you disabled the public IP). Use the admin credentials you set in `terraform.tfvars`.
- From the jumpbox, confirm you can reach each landing zone:
  ```powershell
  Test-NetConnection -ComputerName $dcIps[0] -Port 3389
  Test-NetConnection -ComputerName $jumpPriv -Port 3389
  ```

### 4) Hub routing and firewall (if `deploy_firewall = true`)

- From the jumpbox, prove egress flows through the firewall SNAT:
  ```powershell
  (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing).Content
  ```
  The returned IP should match `$fwPublic`.
- Trace a public destination to see the first hop is the firewall private IP:
  ```powershell
  tracert 8.8.8.8
  ```
  Hop 1 should show `$fwPrivate`.

### 5) Identity VNet checks

- Use the identity VM IPs from `$dcIps` to confirm reachability from the jumpbox:
  ```powershell
  foreach ($dc in $dcIps) { Test-NetConnection -ComputerName $dc -Port 3389 }
  ```
- If you promoted the VM(s) to run DNS/AD DS, verify name resolution works from the jumpbox:
  ```powershell
  Resolve-DnsName www.microsoft.com
  ```
  (If you have not configured DNS on the identity VMs yet, expect this to fail until you do.)

### 6) Management zone

- From your local machine, RDP to `$jumpPub` (or via VPN) to confirm inbound access aligns with your NSG rules.
- From the jumpbox, reach the hub management subnet to prove peering and UDRs:
  ```powershell
  Test-NetConnection -ComputerName $fwPrivate -Port 443
  ```
- If Log Analytics is on, confirm the workspace exists:
  ```powershell
  az monitor log-analytics workspace show --ids $(terraform output -raw log_analytics_workspace_id) --query "provisioningState"
  ```

### 7) Shared services (if deployed)

- Key Vault connectivity (a 403 response still proves network reachability):
  ```powershell
  $kv = terraform output -raw keyvault_uri
  Invoke-WebRequest -Uri $kv -UseBasicParsing
  ```
- Storage DNS resolution:
  ```powershell
  nslookup "$(terraform output -raw storage_account_name).blob.core.windows.net"
  ```
- SQL reachability:
  ```powershell
  Test-NetConnection -ComputerName (terraform output -raw sql_server_fqdn) -Port 1433
  ```

### 8) Workload and load balancer (if `deploy_load_balancer = true`)

- From your local machine or the jumpbox, hit the IIS sample and watch the backend rotate:
  ```powershell
  1..5 | ForEach-Object { (Invoke-WebRequest -Uri "http://$lbIp" -UseBasicParsing).Content }
  ```
  You should see the hostname change between web servers.
- RDP through NAT rules to the web VMs:
  ```powershell
  mstsc /v:$lbIp:3389  # web01
  mstsc /v:$lbIp:3390  # web02 (if configured)
  ```
- If AKS is enabled, pull credentials with the output names:
  ```powershell
  az aks get-credentials --resource-group (terraform output -raw workload_prod_vnet_id | Split-Path -Leaf) `
    --name (terraform output -raw aks_cluster_name)
  kubectl get nodes
  ```

### 9) VPN and on-prem simulation (if `deploy_onprem_simulation = true`)

- RDP to the on-prem management VM using `$onpremPub` and your admin credentials.
- From that VM, prove the tunnel reaches Azure:
  ```powershell
  Test-NetConnection -ComputerName $jumpPriv -Port 3389
  Test-NetConnection -ComputerName $fwPrivate -Port 443
  ```
- From the jumpbox, reach back to the on-prem management VM:
  ```powershell
  Test-NetConnection -ComputerName 10.100.1.4 -Port 3389
  ```
  (Use your actual on-prem servers subnet IP if you customized it.)

### 10) Observability spot checks

- Run a quick query against Log Analytics (expect results only if you installed agents or enabled diagnostics):
  ```powershell
  az monitor log-analytics query `
    -w $(terraform output -raw log_analytics_workspace_id) `
    --analytics-query "union * | take 5" `
    --query "Tables[0].Rows" -o table
  ```
- If you turned on VNet Flow Logs, check the storage account for the `insights-logs-networkwatcherflowevent` container to confirm traffic is being written.

### 11) Clean up

- When finished, destroy to avoid ongoing cost:
  ```powershell
  terraform destroy
  ```
- For partial cleanup, target modules (e.g., `terraform destroy -target=module.workload_prod`) after reviewing the plan.

