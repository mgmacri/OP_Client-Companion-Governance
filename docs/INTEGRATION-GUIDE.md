# Integration Guide: Using OP_Client-Companion-Governance in an App Repo

This guide shows how to integrate this governance repository into an application repository using **thin wrapper workflows**.

Example application repository:

- https://github.com/mgmacri/OP_Client-Companion

## Goals

- App repos keep workflow logic minimal (caller-only).
- Governance repo owns CI/CD logic (called workflows) and composite actions.
- App repos get consistent, auditable CI/CD across projects.

---

## 1) Prerequisites

### A. Repository access

Your app repo must be able to call this repo’s reusable workflows:

- Public repos: no extra setup.
- Private repos: ensure the org/repo settings allow reusable workflow access.

### B. Decide your ref strategy

In the app repo, reference this governance repo by:

- `@main` (fast iteration; least secure), or
- a release tag like `@v1` (recommended), or
- a full commit SHA (most secure).

For production usage, prefer `@v1` or a SHA.

---

## 2) Replace app-local CI with wrapper workflows

In `mgmacri/OP_Client-Companion`, the app code lives under `app/client-companion`, so wrappers should set:

- `working-directory: "app/client-companion"`

In your app repo, the workflows under `.github/workflows/` should become **wrappers** that call this repo.

Below are examples for an app that lives at `app/client-companion`.

### A. PR Check wrapper (`.github/workflows/pr-check.yml`)

```yaml
name: PR Check

on:
  pull_request:
    branches: [main, develop]

jobs:
  pr-check:
    uses: mgmacri/OP_Client-Companion-Governance/.github/workflows/pr-check.yml@main
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

### B. CI wrapper (`.github/workflows/ci.yml`)

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  workflow_dispatch:

permissions:
  contents: read

jobs:
  ci:
    uses: mgmacri/OP_Client-Companion-Governance/.github/workflows/ci.yml@main
    with:
      node-version: "20"
      pnpm-version: "9"
      working-directory: "app/client-companion"
```

If you already have an app-local CI workflow (for example, one that runs `actions/setup-node` + `pnpm` directly), replace it with this wrapper so governance owns the implementation.

### C. Release wrapper (`.github/workflows/release.yml`)

```yaml
name: Release

on:
  push:
    tags: ['v*.*.*']
  workflow_dispatch:
    inputs:
      environment:
        required: true
        type: choice
        options: [staging, production]
        default: staging
      dry-run:
        required: false
        type: boolean
        default: false

jobs:
  release:
    uses: mgmacri/OP_Client-Companion-Governance/.github/workflows/release.yml@main
    with:
      environment: ${{ inputs.environment || 'staging' }}
      dry-run: ${{ inputs.dry-run || false }}
      node-version: "20"
      pnpm-version: "9"
      working-directory: "app/client-companion"
    permissions:
      id-token: write
      contents: write
      packages: write
      attestations: write
```

### D. Scheduled maintenance wrapper (`.github/workflows/maintenance.yml`)

```yaml
name: Scheduled Maintenance

on:
  schedule:
    - cron: '0 6 * * 1'
  workflow_dispatch:

jobs:
  maintenance:
    uses: mgmacri/OP_Client-Companion-Governance/.github/workflows/schedule.yml@main
    with:
      node-version: "20"
      pnpm-version: "9"
      working-directory: "app/client-companion"
      run-dependency-audit: true
      run-stale-cleanup: true
      run-license-check: true
    permissions:
      contents: read
      issues: write
      pull-requests: write
      security-events: write
```

---

## 3) Align branch protection with emitted job names

Your branch protection required status checks must match the job names produced by the called workflows.

- Decide the required checks list (e.g., lint/test/compliance/security).
- Ensure the governance workflows’ job names stay stable.
- If you rename jobs, update branch protection and governance docs in the same PR.

---

## 4) Common pitfalls

- **Unpinned actions in app repo:** app wrappers should not use third-party actions at all.
- **Wrong working directory:** set `working-directory` to where your `package.json`/`pnpm-lock.yaml` live.
- **Private repo access:** reusable workflows can fail if cross-repo access isn’t allowed.

---

## 5) Recommended next hardening steps

- Tag governance releases (e.g., `v1`) and update app repos to use that tag.
- Add CODEOWNERS rules requiring review for `.github/workflows/**` changes.
- Ensure the app repo runs the compliance scan (via governance `pr-check.yml`).
