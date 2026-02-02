# App Repository CI Wrapper Examples

This document provides complete examples for calling owl-governance reusable workflows from your application repository.

## Directory Structure

```plaintext
your-app-repo/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # Main CI (thin wrapper)
│   │   ├── pr-check.yml        # PR validation (thin wrapper)
│   │   ├── release.yml         # Release pipeline (thin wrapper)
│   │   └── maintenance.yml     # Scheduled tasks (thin wrapper)
│   ├── copilot-instructions.md # Copy from governance templates
│   └── pull-request-template.md
├── app/
│   └── client-companion/       # Your application code
│       ├── package.json
│       ├── pnpm-lock.yaml
│       └── src/
└── ...
```

---

## Workflow: CI (ci.yml)

```yaml
# =============================================================================
# APP REPO: CI Workflow
# =============================================================================
# Thin wrapper calling governance CI workflow for build/test.
# =============================================================================

name: CI

on:
  push:
    branches:
      - main
      - develop
  pull_request:
  workflow_dispatch:

# Prevent concurrent runs on the same branch
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  ci:
    name: Build & Test
    uses: ORG/owl-governance/.github/workflows/pr-check.yml@main
    with:
      node-version: "20"
      pnpm-version: "9"
      working-directory: "app/client-companion"
      run-security-scan: true
      fail-on-compliance-violation: true
    permissions:
      contents: read
      pull-requests: read
      security-events: write
```

---

## Workflow: PR Check (pr-check.yml)

```yaml
# =============================================================================
# APP REPO: PR Check Workflow
# =============================================================================
# Validates PRs with lint, test, security, and compliance checks.
# =============================================================================

name: PR Check

on:
  pull_request:
    branches:
      - main
      - develop
    types:
      - opened
      - synchronize
      - reopened
      - ready_for_review

# Skip draft PRs
concurrency:
  group: pr-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  # Skip if draft
  check-draft:
    runs-on: ubuntu-latest
    if: ${{ !github.event.pull_request.draft }}
    steps:
      - run: echo "PR is ready for review"

  # Call governance workflow
  pr-check:
    needs: check-draft
    uses: ORG/owl-governance/.github/workflows/pr-check.yml@main
    with:
      node-version: "20"
      pnpm-version: "9"
      working-directory: "app/client-companion"
      run-security-scan: true
      fail-on-compliance-violation: true
    permissions:
      contents: read
      pull-requests: read
      security-events: write

  # App-specific checks (optional)
  app-specific:
    needs: check-draft
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
        with:
          persist-credentials: false

      - name: Check work-package linkage
        run: |
          # Ensure PR description references a work package or issue
          echo "Checking PR linkage..."
          # Add your custom validation here
```

---

## Workflow: Release (release.yml)

```yaml
# =============================================================================
# APP REPO: Release Workflow
# =============================================================================
# Secure release pipeline with SLSA attestation.
# Triggered by version tags or manual dispatch.
# =============================================================================

name: Release

on:
  push:
    tags:
      - 'v*.*.*'
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        type: choice
        options:
          - staging
          - production
        default: staging
      dry-run:
        description: 'Perform dry run'
        required: false
        type: boolean
        default: false

jobs:
  # Determine environment from tag or input
  prepare:
    runs-on: ubuntu-latest
    outputs:
      environment: ${{ steps.env.outputs.environment }}
    steps:
      - name: Determine environment
        id: env
        run: |
          if [[ "${{ github.event_name }}" == "push" ]]; then
            # Tag push - determine from tag pattern
            TAG="${GITHUB_REF#refs/tags/}"
            if [[ "$TAG" == *"-beta"* ]] || [[ "$TAG" == *"-rc"* ]]; then
              echo "environment=staging" >> "$GITHUB_OUTPUT"
            else
              echo "environment=production" >> "$GITHUB_OUTPUT"
            fi
          else
            # Manual dispatch
            echo "environment=${{ inputs.environment }}" >> "$GITHUB_OUTPUT"
          fi

  # Call governance release workflow
  release:
    needs: prepare
    uses: ORG/owl-governance/.github/workflows/release.yml@main
    with:
      environment: ${{ needs.prepare.outputs.environment }}
      node-version: "20"
      pnpm-version: "9"
      working-directory: "app/client-companion"
      dry-run: ${{ inputs.dry-run || false }}
      create-github-release: true
    permissions:
      id-token: write
      contents: write
      packages: write
      attestations: write

  # Post-release notifications (optional)
  notify:
    needs: release
    if: ${{ !inputs.dry-run }}
    runs-on: ubuntu-latest
    steps:
      - name: Notify release
        run: |
          echo "🚀 Released version ${{ needs.release.outputs.version }}"
          echo "📦 Release URL: ${{ needs.release.outputs.release-url }}"
          # Add Slack/Teams notification here
```

---

## Workflow: Scheduled Maintenance (maintenance.yml)

```yaml
# =============================================================================
# APP REPO: Scheduled Maintenance Workflow
# =============================================================================
# Weekly maintenance: dependency audit, stale cleanup, license check.
# =============================================================================

name: Scheduled Maintenance

on:
  schedule:
    # Every Monday at 6:00 AM UTC
    - cron: '0 6 * * 1'
  workflow_dispatch:
    inputs:
      run-dependency-audit:
        description: 'Run dependency vulnerability audit'
        type: boolean
        default: true
      run-stale-cleanup:
        description: 'Close stale issues and PRs'
        type: boolean
        default: true
      run-license-check:
        description: 'Validate dependency licenses'
        type: boolean
        default: true

jobs:
  maintenance:
    uses: ORG/owl-governance/.github/workflows/schedule.yml@main
    with:
      node-version: "20"
      pnpm-version: "9"
      working-directory: "app/client-companion"
      run-dependency-audit: ${{ inputs.run-dependency-audit || true }}
      run-stale-cleanup: ${{ inputs.run-stale-cleanup || true }}
      run-license-check: ${{ inputs.run-license-check || true }}
      stale-days-before-stale: 60
      stale-days-before-close: 14
    permissions:
      contents: read
      issues: write
      pull-requests: write
      security-events: write
```

---

## Required Repository Settings

### Secrets

No static secrets required! All authentication uses OIDC.

### Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `WORKING_DIRECTORY` | App subdirectory | `app/client-companion` |

### Environments

Create these environments in GitHub Settings:

1. **staging**
   - No approval required
   - Deployment branches: `develop`, tags `*-beta*`, `*-rc*`

2. **production**
   - Require 1 approval
   - Deployment branches: `main` only
   - Wait timer: 10 minutes (optional)

---

## Verification Checklist

After setting up wrappers, verify:

- [ ] PR check runs on pull requests
- [ ] CI runs on push to main/develop
- [ ] Release workflow triggers on version tags
- [ ] Scheduled maintenance runs weekly
- [ ] All status checks appear in branch protection
