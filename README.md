# OP_Client-Companion-Governance

> Centralized governance, reusable workflows, and compliance standards for Clinical/Personal Therapy Companion projects.

[![CI](https://github.com/mgmacri/OP_Client-Companion-Governance/actions/workflows/ci.yml/badge.svg)](https://github.com/mgmacri/OP_Client-Companion-Governance/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## 📋 Overview

This repository provides **organization-wide governance** for clinical and mental health software development. It follows the [Microsoft ISE Centralized Governance Model](https://github.com/microsoft/code-with-engineering-playbook) and enforces security-first, compliance-ready CI/CD practices.

### Key Principles

- **🔒 Security First** - All workflows use SHA-pinned actions and OIDC authentication
- **✅ Compliance Ready** - Built for HIPAA, GDPR, and clinical audit requirements
- **🔄 Reusable** - Thin wrappers in app repos call centralized workflows
- **🤖 AI-Assisted** - Agent specifications for Copilot-powered code review and planning
- **📊 Auditable** - Full traceability from issue to deployment

---

## 📁 Repository Structure

```plaintext
OP_Client-Companion-Governance/
├── .github/
│   ├── actions/                    # Reusable composite actions
│   │   ├── security-scan/          # Security scanning (secrets, SAST, deps)
│   │   │   ├── action.yml
│   │   │   └── README.md
│   │   └── setup-node-pnpm/        # Node.js + pnpm environment setup
│   │       ├── action.yml
│   │       └── README.md
│   └── workflows/                  # Reusable workflow_call workflows
│       ├── ci.yml                  # Continuous integration
│       ├── pr-check.yml            # Pull request validation
│       ├── release.yml             # Secure release pipeline
│       └── schedule.yml            # Scheduled maintenance
├── docs/
│   ├── agents/                     # AI agent specifications
│   │   ├── backend.agent.md
│   │   ├── compliance-tagger.agent.md
│   │   ├── devops.agent.md
│   │   ├── frontend.agent.md
│   │   ├── mobile.agent.md
│   │   ├── planner.agent.md
│   │   ├── qa-compliance.agent.md
│   │   ├── quality-senior-reviewer.agent.md
│   │   ├── release-manager.agent.md
│   │   ├── sdet.agent.md
│   │   └── workflow-audit.agent.md
│   ├── prompts/                    # Reusable prompt templates
│   │   ├── review-architecture.prompt.md
│   │   ├── review-pr-scope.prompt.md
│   │   ├── review-pr.prompt.md
│   │   └── triage-backlog.prompt.md
│   ├── skills/                     # Copilot skill definitions
│   │   ├── ci-quality-gates/
│   │   ├── devops-generate-ci-workflow/
│   │   ├── github-actions-hardening/
│   │   ├── review-guardrails/
│   │   ├── review-pr-scope/
│   │   ├── test-determinism/
│   │   └── timestamps-utc/
│   ├── standards/                  # Compliance documentation
│   │   ├── Agent-Roles-Models.MD
│   │   ├── compliance-legislation.md
│   │   └── DevSecOps-Industry-Standards.md
│   └── templates/                  # Repository templates
│       ├── copilot-instructions.md
│       └── pull-request-template.md
├── scripts/                        # Governance automation scripts
│   ├── Generate-Project-App.ps1
│   └── Generate-Project-Governance.ps1
├── README.md
└── REPO_GOVERNANCE.md
```

---

## 🚀 Quick Start

### 1. Call Reusable Workflows from Your App Repo

Create thin wrapper workflows in your app repository:

**`.github/workflows/pr-check.yml`**
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
      working-directory: "app/client-companion"
      run-security-scan: true
    permissions:
      contents: read
      pull-requests: read
      security-events: write
```

**`.github/workflows/release.yml`**
```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    uses: mgmacri/OP_Client-Companion-Governance/.github/workflows/release.yml@main
    with:
      environment: production
      node-version: "20"
      working-directory: "app/client-companion"
    permissions:
      id-token: write
      contents: write
      packages: write
      attestations: write
```

**`.github/workflows/maintenance.yml`**
```yaml
name: Scheduled Maintenance

on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6am UTC
  workflow_dispatch:

jobs:
  maintenance:
    uses: mgmacri/OP_Client-Companion-Governance/.github/workflows/schedule.yml@main
    with:
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

## 📦 Reusable Workflows

### PR Check (`pr-check.yml`)

Validates pull requests before merge with lint, test, security, and compliance checks.

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `node-version` | string | `"20"` | Node.js version |
| `pnpm-version` | string | `"9"` | pnpm version |
| `working-directory` | string | `"."` | App working directory |
| `run-security-scan` | boolean | `true` | Enable security scanning |
| `fail-on-compliance-violation` | boolean | `true` | Fail on compliance issues |

### Release (`release.yml`)

Secure release pipeline with SLSA attestation and OIDC authentication.

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `environment` | string | **required** | Deployment environment |
| `node-version` | string | `"20"` | Node.js version |
| `working-directory` | string | `"."` | App working directory |
| `dry-run` | boolean | `false` | Perform dry run |
| `create-github-release` | boolean | `true` | Create GitHub release |

| Output | Description |
|--------|-------------|
| `version` | Released version number |
| `release-url` | URL to GitHub release |

### Schedule (`schedule.yml`)

Automated maintenance including dependency audits and stale cleanup.

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `run-dependency-audit` | boolean | `true` | Run vulnerability audit |
| `run-stale-cleanup` | boolean | `true` | Close stale issues/PRs |
| `run-license-check` | boolean | `true` | Validate licenses |
| `stale-days-before-stale` | number | `60` | Days before marking stale |
| `stale-days-before-close` | number | `14` | Days before closing |

---

## 🔒 Security Best Practices

### OIDC Authentication

All workflows use OIDC (OpenID Connect) for cloud authentication—no static secrets required.

```yaml
permissions:
  id-token: write  # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS Credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502 # v4.0.2
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
          aws-region: us-east-1
```

### SHA-Pinned Actions

All actions MUST be pinned by SHA, not version tag:

```yaml
# ✅ Correct - SHA pinned with version comment
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

# ❌ Wrong - Version tag only
uses: actions/checkout@v4
```

### Branch Protection Rules

Configure these rules on `main` branch:

| Rule | Setting |
|------|---------|
| Require pull request reviews | ✅ 1 approval minimum |
| Dismiss stale PR approvals | ✅ Enabled |
| Require status checks | ✅ `lint`, `test`, `compliance` |
| Require branches to be up to date | ✅ Enabled |
| Require linear history | ✅ No merge commits |
| Include administrators | ✅ Rules apply to admins |
| Restrict force pushes | ✅ Disabled |
| Restrict deletions | ✅ Disabled |

---

## 🤖 AI Agents

### Agent Coverage Matrix

| Agent | Responsibility | Model |
|-------|---------------|-------|
| `planner` | Sprint planning, work package creation | GPT-5.2 |
| `backend` | Backend API development | GPT-5.2-Codex |
| `frontend` | React/Redux development | GPT-5.2-Codex |
| `mobile` | React Native development | GPT-5.2-Codex |
| `devops` | CI/CD workflow authoring | GPT-5.2-Codex |
| `sdet` | Test generation and coverage | Claude Sonnet 4.5 |
| `qa-compliance` | Compliance testing | Claude Opus 4.5 |
| `quality-senior-reviewer` | Code review | Claude Opus 4.5 |
| `workflow-audit` | Workflow security review | Claude Opus 4.5 |
| `compliance-tagger` | Label enforcement | Claude Sonnet 4.5 |
| `release-manager` | Release orchestration | GPT-5.2-Codex |

### Using Agents

Reference agents in your Copilot instructions:

```markdown
@workspace Use the qa-compliance agent to review this PR for HIPAA violations.

@workspace Apply the workflow-audit checklist to .github/workflows/release.yml
```

---

## 📊 Compliance

### Supported Frameworks

- **HIPAA** - Protected Health Information handling
- **GDPR** - EU data protection requirements
- **SOC 2** - Security controls
- **SLSA** - Supply chain security

### Audit Trail Requirements

All actions are logged with:

- UTC timestamps
- Actor identification
- Workflow run ID
- Commit SHA
- Environment

---

## 🛠️ Development

### Adding a New Workflow

1. Create workflow in `.github/workflows/`
2. Use `workflow_call` trigger with documented inputs
3. Pin all actions by SHA
4. Add explicit `permissions` block
5. Update this README
6. Have `workflow-audit` agent review

### Adding a New Agent

1. Create agent spec in `docs/agents/`
2. Follow the chatagent markdown format
3. Define required skills
4. Document input/output formats
5. Add to agent coverage matrix

---

## 📝 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🔗 Related Resources

- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Microsoft Code With Engineering Playbook](https://microsoft.github.io/code-with-engineering-playbook/)
- [SLSA Framework](https://slsa.dev/)
- [OpenSSF Scorecard](https://securityscorecards.dev/)

