# =============================================================================
# AZURE WORKBOOKS MODULE
# Pre-built workbooks for VM, Network, and Firewall monitoring
# =============================================================================

# Generate UUIDs for workbook names (required by Azure)
resource "random_uuid" "vm_workbook" {
  count = var.deploy_vm_workbook ? 1 : 0
}

resource "random_uuid" "network_workbook" {
  count = var.deploy_network_workbook ? 1 : 0
}

resource "random_uuid" "firewall_workbook" {
  count = var.deploy_firewall_workbook ? 1 : 0
}

# VM Performance Workbook
resource "azurerm_application_insights_workbook" "vm_performance" {
  count               = var.deploy_vm_workbook ? 1 : 0
  name                = random_uuid.vm_workbook[0].result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "VM Performance Dashboard"
  tags                = var.tags

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## 🖥️ VM Performance Dashboard\nReal-time monitoring of CPU, Memory, Disk, and Network metrics for all VMs in the landing zone."
        }
        name = "header"
      },
      {
        type = 3
        content = {
          version    = "KqlItem/1.0"
          query      = <<-EOT
            Perf
            | where ObjectName == "Processor" and CounterName == "% Processor Time"
            | summarize AvgCPU = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
            | render timechart
          EOT
          size       = 0
          title      = "CPU Utilization by VM"
          queryType  = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
        name = "cpu-chart"
      },
      {
        type = 3
        content = {
          version    = "KqlItem/1.0"
          query      = <<-EOT
            Perf
            | where ObjectName == "Memory" and CounterName == "% Committed Bytes In Use"
            | summarize AvgMemory = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
            | render timechart
          EOT
          size       = 0
          title      = "Memory Utilization by VM"
          queryType  = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
        name = "memory-chart"
      },
      {
        type = 3
        content = {
          version    = "KqlItem/1.0"
          query      = <<-EOT
            Perf
            | where ObjectName == "LogicalDisk" and CounterName == "% Free Space"
            | where InstanceName != "_Total"
            | summarize AvgFreeSpace = avg(CounterValue) by Computer, InstanceName
            | order by AvgFreeSpace asc
          EOT
          size       = 0
          title      = "Disk Free Space"
          queryType  = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
        name = "disk-table"
      }
    ]
    isLocked = false
  })
}

# Network Traffic Workbook
resource "azurerm_application_insights_workbook" "network_traffic" {
  count               = var.deploy_network_workbook ? 1 : 0
  name                = random_uuid.network_workbook[0].result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "Network Traffic Dashboard"
  tags                = var.tags

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## 🌐 Network Traffic Dashboard\nMonitor network flows, bandwidth usage, and connectivity across the landing zone."
        }
        name = "header"
      },
      {
        type = 3
        content = {
          version    = "KqlItem/1.0"
          query      = <<-EOT
            Perf
            | where ObjectName == "Network Adapter" and CounterName == "Bytes Total/sec"
            | summarize TotalBytes = sum(CounterValue) by Computer, bin(TimeGenerated, 5m)
            | render timechart
          EOT
          size       = 0
          title      = "Network Throughput by VM"
          queryType  = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
        name = "network-throughput"
      },
      {
        type = 3
        content = {
          version    = "KqlItem/1.0"
          query      = <<-EOT
            AzureNetworkAnalytics_CL
            | where TimeGenerated > ago(1h)
            | summarize FlowCount = count() by FlowStatus_s, bin(TimeGenerated, 5m)
            | render columnchart
          EOT
          size       = 0
          title      = "Network Flow Status"
          queryType  = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
        name = "flow-status"
      }
    ]
    isLocked = false
  })
}

# Firewall Analytics Workbook
resource "azurerm_application_insights_workbook" "firewall" {
  count               = var.deploy_firewall_workbook ? 1 : 0
  name                = random_uuid.firewall_workbook[0].result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "Azure Firewall Analytics"
  tags                = var.tags

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## 🛡️ Azure Firewall Analytics\nMonitor firewall rules, denied traffic, and threat intelligence."
        }
        name = "header"
      },
      {
        type = 3
        content = {
          version    = "KqlItem/1.0"
          query      = <<-EOT
            AzureDiagnostics
            | where Category == "AzureFirewallNetworkRule" or Category == "AzureFirewallApplicationRule"
            | summarize RuleHits = count() by Category, bin(TimeGenerated, 5m)
            | render timechart
          EOT
          size       = 0
          title      = "Firewall Rule Hits Over Time"
          queryType  = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
        name = "rule-hits"
      },
      {
        type = 3
        content = {
          version    = "KqlItem/1.0"
          query      = <<-EOT
            AzureDiagnostics
            | where Category == "AzureFirewallNetworkRule" or Category == "AzureFirewallApplicationRule"
            | where msg_s contains "Deny"
            | summarize DeniedCount = count() by bin(TimeGenerated, 5m)
            | render timechart
          EOT
          size       = 0
          title      = "Denied Traffic Over Time"
          queryType  = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
        name = "denied-traffic"
      },
      {
        type = 3
        content = {
          version    = "KqlItem/1.0"
          query      = <<-EOT
            AzureDiagnostics
            | where Category == "AzureFirewallNetworkRule" or Category == "AzureFirewallApplicationRule"
            | where msg_s contains "Deny"
            | project TimeGenerated, msg_s
            | order by TimeGenerated desc
            | take 50
          EOT
          size       = 0
          title      = "Recent Denied Connections"
          queryType  = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          crossComponentResources = [var.log_analytics_workspace_id]
        }
        name = "denied-details"
      }
    ]
    isLocked = false
  })
}
