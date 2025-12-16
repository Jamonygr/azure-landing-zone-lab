# Pipeline Templates Architecture

This document describes the 3-level templatized pipeline architecture for the Azure Landing Zone lab.

## Overview

The pipeline is organized into three levels of abstraction, enabling maximum reusability and maintainability:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LEVEL 3: ORCHESTRATORS                           │
│  terraform-orchestrator.yml  │  terraform-multi-env.yml             │
│  (Main pipeline)             │  (Multi-environment deploy)          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  LEVEL 2: REUSABLE WORKFLOWS                        │
│  reusable-validate.yml  │  reusable-plan.yml  │  reusable-apply.yml │
│  reusable-security.yml  │  reusable-destroy.yml                     │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   LEVEL 1: COMPOSITE ACTIONS                        │
│  terraform-setup  │  terraform-init  │  terraform-plan              │
│  terraform-apply  │  terraform-destroy  │  security-scan            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Level 1: Composite Actions

Composite actions are reusable step sequences stored in `.github/actions/`. They encapsulate common patterns into single, reusable units.

### Location

```
.github/actions/
├── terraform-setup/
│   └── action.yml
├── terraform-init/
│   └── action.yml
├── terraform-plan/
│   └── action.yml
├── terraform-apply/
│   └── action.yml
├── terraform-destroy/
│   └── action.yml
└── security-scan/
    └── action.yml
```

### Available Actions

| Action | Purpose | Key Inputs |
|--------|---------|------------|
| `terraform-setup` | Setup Terraform and Azure authentication | `terraform_version`, `azure_credentials` |
| `terraform-init` | Initialize Terraform backend | `working_directory`, `backend_*` |
| `terraform-plan` | Execute plan with change detection | `var_file`, outputs: `has_changes` |
| `terraform-apply` | Apply with summary generation | `plan_file`, `add_count`, etc. |
| `terraform-destroy` | Destroy with confirmation check | `var_file`, `confirm` |
| `security-scan` | Run tfsec and Checkov | `working_directory`, `soft_fail` |

### Usage Example

```yaml
steps:
  - uses: ./.github/actions/terraform-setup
    with:
      terraform_version: '1.9.0'
      azure_credentials: ${{ secrets.AZURE_CREDENTIALS }}

  - uses: ./.github/actions/terraform-plan
    id: plan
    with:
      var_file: 'environments/lab.tfvars'
```

---

## Level 2: Reusable Workflows

Reusable workflows are complete job definitions that can be called from other workflows using `workflow_call`.

### Location

```
.github/workflows/
├── reusable-validate.yml
├── reusable-security.yml
├── reusable-plan.yml
├── reusable-apply.yml
└── reusable-destroy.yml
```

### Available Workflows

#### reusable-validate.yml

Performs format checking and validation.

**Inputs:**
| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `terraform_version` | string | `1.9.0` | Terraform version |
| `working_directory` | string | `.` | Working directory |

**Outputs:**
| Output | Description |
|--------|-------------|
| `format_result` | Format check result |
| `validate_result` | Validation result |

**Usage:**
```yaml
jobs:
  validate:
    uses: ./.github/workflows/reusable-validate.yml
    with:
      terraform_version: '1.9.0'
```

---

#### reusable-security.yml

Runs security scanning tools (tfsec, Checkov, TFLint).

**Inputs:**
| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `working_directory` | string | `.` | Directory to scan |
| `run_tfsec` | boolean | `true` | Run tfsec |
| `run_checkov` | boolean | `true` | Run Checkov |
| `run_tflint` | boolean | `true` | Run TFLint |
| `soft_fail` | boolean | `true` | Continue on findings |

**Usage:**
```yaml
jobs:
  security:
    uses: ./.github/workflows/reusable-security.yml
    with:
      run_tfsec: true
      run_checkov: true
      soft_fail: true
```

---

#### reusable-plan.yml

Executes Terraform plan with change detection and PR comments.

**Inputs:**
| Input | Type | Required | Description |
|-------|------|----------|-------------|
| `terraform_version` | string | No | Terraform version |
| `environment` | string | Yes | Target environment |
| `var_file` | string | Yes | Variables file path |

**Secrets:**
- `AZURE_CREDENTIALS`
- `TF_STATE_RG`
- `TF_STATE_SA`

**Outputs:**
| Output | Description |
|--------|-------------|
| `has_changes` | Whether plan has changes |
| `add` | Resources to add |
| `change` | Resources to change |
| `destroy` | Resources to destroy |

**Usage:**
```yaml
jobs:
  plan:
    uses: ./.github/workflows/reusable-plan.yml
    with:
      environment: 'lab'
      var_file: 'environments/lab.tfvars'
    secrets:
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
      TF_STATE_RG: ${{ secrets.TF_STATE_RG }}
      TF_STATE_SA: ${{ secrets.TF_STATE_SA }}
```

---

#### reusable-apply.yml

Applies Terraform plan from artifact.

**Inputs:**
| Input | Type | Required | Description |
|-------|------|----------|-------------|
| `environment` | string | Yes | Target environment |
| `plan_artifact` | string | Yes | Artifact name containing plan |
| `add_count` | string | No | Resources added (for summary) |
| `change_count` | string | No | Resources changed |
| `destroy_count` | string | No | Resources destroyed |

**Usage:**
```yaml
jobs:
  apply:
    needs: plan
    uses: ./.github/workflows/reusable-apply.yml
    with:
      environment: 'lab'
      plan_artifact: 'tfplan-lab-${{ github.sha }}'
      add_count: ${{ needs.plan.outputs.add }}
    secrets:
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
      TF_STATE_RG: ${{ secrets.TF_STATE_RG }}
      TF_STATE_SA: ${{ secrets.TF_STATE_SA }}
```

---

#### reusable-destroy.yml

Destroys infrastructure with confirmation.

**Inputs:**
| Input | Type | Required | Description |
|-------|------|----------|-------------|
| `environment` | string | Yes | Target environment |
| `var_file` | string | Yes | Variables file |
| `destroy_confirm` | string | Yes | Must be "DESTROY" |

**Usage:**
```yaml
jobs:
  destroy:
    uses: ./.github/workflows/reusable-destroy.yml
    with:
      environment: 'lab'
      var_file: 'environments/lab.tfvars'
      destroy_confirm: ${{ inputs.destroy_confirm }}
    secrets:
      AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
      TF_STATE_RG: ${{ secrets.TF_STATE_RG }}
      TF_STATE_SA: ${{ secrets.TF_STATE_SA }}
```

---

## Level 3: Orchestrators

Orchestrators are the main entry-point workflows that combine reusable workflows.

### terraform-orchestrator.yml

The primary pipeline for single-environment deployments.

**Features:**
- Triggered on push to main (Terraform files)
- Triggered on PRs to main
- Manual dispatch with environment selection
- Sequential stages: Validate → Security → Plan → Apply/Destroy

**Workflow Dispatch Inputs:**
| Input | Options | Description |
|-------|---------|-------------|
| `environment` | dev, lab, prod | Target environment |
| `action` | plan, apply, destroy | Action to perform |
| `destroy_confirm` | string | Type "DESTROY" to confirm |

### terraform-multi-env.yml

Multi-environment deployment pipeline.

**Features:**
- Deploy to multiple environments in sequence
- Automatic environment gating (dev → lab → prod)
- Selective environment deployment
- Skip security option for speed

**Workflow Dispatch Inputs:**
| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `deploy_dev` | boolean | true | Deploy to DEV |
| `deploy_lab` | boolean | true | Deploy to LAB |
| `deploy_prod` | boolean | false | Deploy to PROD |
| `skip_security` | boolean | false | Skip security scans |

---

## Benefits of This Architecture

### 1. Reusability
- Composite actions can be used in any workflow
- Reusable workflows prevent duplication
- Changes propagate automatically

### 2. Maintainability
- Single source of truth for each operation
- Clear separation of concerns
- Easy to update individual components

### 3. Flexibility
- Mix and match components as needed
- Easy to add new environments
- Support for custom workflows

### 4. Testability
- Test each level independently
- Easy to debug specific components
- Clear failure boundaries

---

## Adding a New Environment

1. Create tfvars file: `environments/newenv.tfvars`
2. Add to orchestrator dropdown options
3. (Optional) Configure GitHub environment protection rules

No changes needed to Level 1 or Level 2 components!

---

## Extending the Pipeline

### Add a New Composite Action

```yaml
# .github/actions/my-action/action.yml
name: 'My Custom Action'
description: 'Does something useful'

inputs:
  my_input:
    description: 'Input description'
    required: true

runs:
  using: 'composite'
  steps:
    - name: Do Something
      shell: bash
      run: echo "Hello ${{ inputs.my_input }}"
```

### Add a New Reusable Workflow

```yaml
# .github/workflows/reusable-my-workflow.yml
name: My Workflow

on:
  workflow_call:
    inputs:
      my_input:
        type: string
        required: true

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - uses: ./.github/actions/my-action
        with:
          my_input: ${{ inputs.my_input }}
```

---

## See Also

- [Pipeline Overview](pipeline.md) - Original pipeline documentation
- [GitHub Actions Docs](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Composite Actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
