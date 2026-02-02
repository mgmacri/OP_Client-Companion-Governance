# Repository Governance

This repository defines organization-wide governance, standards, and templates for the Client Companion clinical software ecosystem.

---

## 📋 Governance Scope

This repository governs:

1. **CI/CD Workflows** - Reusable GitHub Actions workflows for all app repos
2. **Security Standards** - OIDC, branch protection, secret scanning
3. **Compliance Requirements** - HIPAA, GDPR, audit trail standards
4. **AI Agent Specifications** - Copilot agent roles and skills
5. **Code Review Standards** - PR templates, review guardrails

---

## 🔄 Workflow Governance

### Reusable Workflows

| Workflow | Purpose | Required Checks |
|----------|---------|-----------------|
| `pr-check.yml` | PR validation | lint, test, security, compliance |
| `release.yml` | Secure releases | SLSA attestation, environment gates |
| `schedule.yml` | Maintenance | dependency audit, stale cleanup |
| `ci.yml` | Build & test | lint, test, build |

### Action Pinning Policy

All GitHub Actions MUST be pinned by SHA:

```yaml
# ✅ Required format
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

# ❌ Forbidden
uses: actions/checkout@v4
uses: actions/checkout@main
```

### Workflow Change Process

1. Create PR with workflow changes
2. `workflow-audit` agent reviews for security
3. DevOps team approval required
4. All CI checks must pass
5. Changes take effect immediately on merge

---

## 🔒 Security Governance

### Authentication

- **OIDC Required** - No static secrets for cloud authentication
- **Token Scoping** - Minimal permissions per workflow
- **Environment Gates** - Production requires approval

### Branch Protection

All app repos MUST configure:

| Rule | Requirement |
|------|-------------|
| Required reviews | Minimum 1 approval |
| Dismiss stale approvals | Enabled |
| Required status checks | lint, test, security, compliance |
| Linear history | Enabled |
| Force push restriction | Enabled |

### Secret Management

- No secrets in repository settings
- OIDC for all cloud authentication
- Environment-scoped secrets only when unavoidable
- Quarterly access reviews

---

## ✅ Compliance Governance

### Required Labels

Every PR touching application code MUST have:

| Label Category | Examples |
|----------------|----------|
| Compliance | `compliance:hipaa`, `compliance:gdpr`, `compliance:audit` |
| Type | `type:feature`, `type:bugfix`, `type:refactor` |
| Security (if applicable) | `security:critical`, `security:moderate` |

### Audit Requirements

All changes must maintain:

1. **Traceability** - PR linked to issue/work package
2. **Timestamps** - UTC server-side only
3. **Determinism** - No random/non-deterministic logic
4. **Consent Gates** - User consent before data submission

### Compliance Violations

Workflows MUST fail on:

- Missing compliance labels
- UTC timestamp violations
- Non-deterministic patterns in production code
- Security scan critical findings

---

## 🤖 Agent Governance

### Agent Approval Matrix

| Agent | Approval Level | Review By |
|-------|----------------|-----------|
| `planner` | Self-review | Human architect |
| `backend`, `frontend`, `mobile` | PR review | `quality-senior-reviewer` |
| `devops` | PR review + DevOps | `workflow-audit` |
| `qa-compliance` | Human override | Compliance team |
| `release-manager` | Automated | Environment gates |

### Agent Modification Policy

Changes to agent specifications require:

1. RFC document describing changes
2. Impact analysis on existing workflows
3. Approval from agent owner (per `CODEOWNERS`)
4. 48-hour review period

---

## 📊 Metrics & Reporting

### Weekly Metrics

- PRs merged with/without compliance labels
- Security findings (critical, high, moderate)
- Stale issues closed
- Release frequency

### Quarterly Reviews

- Dependency vulnerability trends
- Agent effectiveness evaluation
- Workflow performance optimization
- Access control audit

---

## 🔗 Related Documents

- [README.md](README.md) - Repository overview and quick start
- [OIDC Best Practices](docs/standards/oidc-branch-protection.md) - Security configuration
- [App CI Wrapper Examples](docs/templates/app-ci-wrapper-examples.md) - Integration guide
- [DevSecOps Standards](docs/standards/DevSecOps-Industry-Standards.md) - Industry standards

---

## 📝 Change Log

| Date | Version | Change |
|------|---------|--------|
| 2026-02-01 | 1.0.0 | Initial governance structure |

