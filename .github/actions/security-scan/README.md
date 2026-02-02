# Security Scan Action

Composite action for comprehensive security scanning including secret detection, SAST, and dependency vulnerability checks.

## Usage

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

  - name: Run security scan
    uses: ORG/owl-governance/.github/actions/security-scan@main
    with:
      working-directory: "app/client-companion"
      fail-on-findings: true
      severity-threshold: "high"
```

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `working-directory` | No | `"."` | Directory to scan |
| `fail-on-findings` | No | `"true"` | Fail workflow on security issues |
| `scan-secrets` | No | `"true"` | Enable secret detection |
| `scan-sast` | No | `"true"` | Enable static analysis |
| `scan-dependencies` | No | `"true"` | Enable dependency scanning |
| `severity-threshold` | No | `"high"` | Minimum severity to report |

## Outputs

| Output | Description |
|--------|-------------|
| `secrets-found` | Whether secrets were detected |
| `vulnerabilities-found` | Whether vulnerabilities were found |
| `scan-report` | Path to consolidated JSON report |

## Scans Performed

### 1. Secret Detection
Detects hardcoded secrets and credentials:
- API keys and tokens
- Passwords and connection strings
- Private keys (RSA, SSH)
- GitHub, Slack, AWS, OpenAI tokens

### 2. Static Analysis (SAST)
Identifies dangerous code patterns:
- `eval()` and `Function()` usage
- SQL injection vectors
- XSS vulnerabilities (`innerHTML`, `dangerouslySetInnerHTML`)
- Command injection (`child_process.exec`, `shell: true`)

### 3. Dependency Vulnerability Scan
Checks for known vulnerabilities:
- npm/pnpm audit integration
- Configurable severity threshold (low, medium, high, critical)
- Automatic issue creation for findings

## Example with Custom Configuration

```yaml
- name: Security scan (dependencies only)
  uses: ORG/owl-governance/.github/actions/security-scan@main
  with:
    scan-secrets: false
    scan-sast: false
    scan-dependencies: true
    severity-threshold: "moderate"
    fail-on-findings: false
```

## Report Format

The action generates a JSON report at `security-scan-report.json`:

```json
{
  "timestamp": "2026-02-01T10:30:00Z",
  "working_directory": "app/client-companion",
  "scans": {
    "secrets": { "enabled": true, "found": false },
    "sast": { "enabled": true, "issues": 0 },
    "dependencies": { "enabled": true, "vulnerabilities_found": false }
  },
  "severity_threshold": "high",
  "fail_on_findings": true
}
```

## Integration with PR Check

This action is automatically called by the `pr-check.yml` reusable workflow. To customize:

```yaml
jobs:
  pr-check:
    uses: ORG/owl-governance/.github/workflows/pr-check.yml@main
    with:
      run-security-scan: true
      fail-on-compliance-violation: true
```
