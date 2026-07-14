# Security scanner exceptions

This repository is a cost-conscious learning lab. Exceptions must be narrowly
scoped, have a compensating control, and be reviewed before their expiry date.
The repository owner is responsible for the review.

| Scanner/rule | Scope | Rationale and compensating control | Owner | Review by |
|---|---|---|---|---|
| Trivy AZU-0068 | modules/compute/windows-vm/main.tf | False positive: the VM consumes the separately declared NIC through network_interface_ids. Terraform tests and validation protect this relationship. | Repository owner | 2027-01-31 |
| Trivy AZU-0068 | landing-zones/networking/secondary-region/main.tf | False positive across a composed module boundary; the identity module creates and attaches the NIC. | Repository owner | 2027-01-31 |
| Trivy AZU-0049 / Checkov CKV_AZURE_12 | VNet flow-log retention | Seven-day retention limits recurring lab cost. Production-like deployments must raise retention to their policy requirement. | Repository owner | 2027-01-31 |
| Trivy AZU-0016 | modules/keyvault/main.tf | Purge protection is irreversible and intentionally disabled so disposable lab vaults can be recreated. Soft delete, state versioning, and verified pre-change backups reduce accidental-loss risk. | Repository owner | 2027-01-31 |
| Checkov CKV_AZURE_151 | VM modules and simulated/secondary landing-zone roots | Encryption at host requires the subscription feature and is optional for low-friction lab profiles. The production-like profile enables it; other profiles require an explicit opt-in after the feature is registered. | Repository owner | 2027-01-31 |
| Checkov rules in .checkov.yml | Rule-specific Terraform resources | Premium HA, customer-managed keys, and private-only networking are intentionally optional to keep the lab deployable at low cost. The private-endpoint, diagnostic, encryption, and WAF controls remain available as explicit flags. | Repository owner | 2027-01-31 |

An exception is not permission to ignore a new alert. Findings outside the
listed rule and path combinations must fail CI and be investigated.
