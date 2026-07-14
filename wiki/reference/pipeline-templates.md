# Pipeline templates

The repository now uses one maintained workflow rather than copy-and-paste
workflow templates. See the [pipeline reference](pipeline.md) and
`.github/workflows/terraform.yml`.

Reusable local actions are implementation details. External actions inside the
workflow and local actions are pinned to complete commit SHAs.
