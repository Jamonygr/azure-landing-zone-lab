# Outputs reference

The generated [root Terraform reference](../../TERRAFORM.md#outputs) is the
canonical output list. It is regenerated from `outputs.tf` in CI, preventing
this page from drifting from the public interface.

Output groups include:

- Hub networking, Firewall, VPN, and Application Gateway addresses.
- Identity VNet and domain-controller addresses.
- Management VNet, jumpbox, and Log Analytics identifiers.
- Shared-service Key Vault, Storage, and SQL endpoints.
- Workload VNets, AKS, Load Balancer, and Container Apps endpoints.
- Optional on-premises simulation and VPN connection identifiers.
- Backup, Automation, location, resource-group, and connection summaries.

Credential-bearing outputs are intentionally not exposed. Retrieve operational
credentials through Azure RBAC and the target service instead of Terraform
output or CI logs.

## Related pages

- [Variables reference](variables.md)
- [State and secrets](state-and-secrets.md)
- [Testing guide](../testing/lab-testing-guide.md)
