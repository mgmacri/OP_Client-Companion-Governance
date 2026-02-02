{
  "devsecops_standard": {
    "version": "1.0.0",
    "effective_date": "2026-02-01",
    "governance_model": "Centralized Reusable Workflows",
    "architecture": {
      "pattern": "Caller-Called",
      "description": "Application repos act as 'Callers' triggering 'Called' workflows stored in a central Governance Repo."
    },
    "file_structure": {
      "monolithic_ci_prohibited": true,
      "required_files": [
        {
          "filename": ".github/workflows/pr-check.yml",
          "purpose": "Fast feedback (Lint, Test, Secret Scan) on Pull Request events."
        },
        {
          "filename": ".github/workflows/release.yml",
          "purpose": "Compliance, Heavy Security Scans, and Deployment on Push to Main/Tags."
        },
        {
          "filename": ".github/workflows/schedule.yml",
          "purpose": "Nightly drift detection and vulnerability scanning of dormant code."
        }
      ]
    },
    "mandates": [
      {
        "id": "SEC-001",
        "category": "Supply Chain Security",
        "rule": "Third-party actions must be pinned by Commit SHA, not Version Tag.",
        "example": "uses: actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab",
        "rationale": "Version tags are mutable and can be hijacked. SHAs are immutable."
      },
      {
        "id": "SEC-002",
        "category": "Governance",
        "rule": "Security scanning logic (SAST/DAST) must reside in the central governance repository.",
        "rationale": "Prevents developers from modifying or disabling security thresholds."
      },
      {
        "id": "SEC-003",
        "category": "Access Control",
        "rule": "Workflows accessing cloud providers (AWS/Azure/GCP) must use OIDC (OpenID Connect).",
        "rationale": "Eliminates the risk of long-lived static cloud credentials stored in GitHub Secrets."
      },
      {
        "id": "SEC-004",
        "category": "Workflow Permissions",
        "rule": "Top-level permissions must be set to 'contents: read' by default.",
        "rationale": "Adheres to the principle of least privilege."
      }
    ],
    "prohibitions": [
      {
        "id": "BAN-001",
        "category": "Security",
        "rule": "Inline scripts (run: ...) performing complex security tasks or deployments.",
        "rationale": "Inline scripts are untestable, unversioned outside the file, and hard to audit."
      },
      {
        "id": "BAN-002",
        "category": "Secrets Management",
        "rule": "Hardcoded secrets or plain-text environment variables containing sensitive data.",
        "rationale": "Secrets must be stored in GitHub Secrets Vault or an external Vault (HashiCorp)."
      },
      {
        "id": "BAN-003",
        "category": "Configuration",
        "rule": "Use of 'continue-on-error: true' for security scanning steps.",
        "rationale": "Security gates must block the pipeline if critical vulnerabilities are found."
      },
      {
        "id": "BAN-004",
        "category": "Triggers",
        "rule": "Triggering production deployments from 'pull_request' events.",
        "rationale": "Deployments should only occur from trusted, reviewed branches (main/release)."
      }
    ]
  }
}