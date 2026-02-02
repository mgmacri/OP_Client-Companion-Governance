#Requires -Version 7.0
<#!
.SYNOPSIS
Initializes the ORG-GOVERNANCE repository structure with baseline files.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$RootPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-Directory([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function New-File([string]$Path, [string]$Content = "") {
    $dir = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($dir)) {
        New-Directory -Path $dir
    }
    if (-not (Test-Path -LiteralPath $Path)) {
        $Content | Set-Content -Path $Path -Encoding UTF8
    }
}

$root = (Resolve-Path -LiteralPath $RootPath).Path

$paths = @(
    "README.md",
    "REPO_GOVERNANCE.md",
    "docs/standards/DevSecOps-Industry-Standards.md",
    "docs/standards/compliance-legislation.md",
    "docs/standards/Agent-Roles-Models.MD",
    "docs/templates/pull-request-template.md",
    "docs/templates/copilot-instructions.md",
    "docs/agents/backend.agent.md",
    "docs/agents/devops.agent.md",
    "docs/agents/frontend.agent.md",
    "docs/agents/mobile.agent.md",
    "docs/agents/planner.agent.md",
    "docs/agents/qa-compliance.agent.md",
    "docs/agents/quality-senior-reviewer.agent.md",
    "docs/agents/sdet.agent.md",
    "docs/prompts/review-architecture.prompt.md",
    "docs/prompts/review-pr.prompt.md",
    "docs/prompts/review-pr-scope.prompt.md",
    "docs/prompts/triage-backlog.prompt.md",
    "docs/skills/ci-quality-gates/SKILL.md",
    "docs/skills/github-actions-hardening/SKILL.md",
    "docs/skills/devops-generate-ci-workflow/SKILL.md",
    "docs/skills/review-guardrails/SKILL.md",
    "docs/skills/review-pr-scope/SKILL.md",
    "docs/skills/test-determinism/SKILL.md",
    "docs/skills/timestamps-utc/SKILL.md",
    ".github/workflows/pr-check.yml",
    ".github/workflows/release.yml",
    ".github/workflows/schedule.yml",
    ".github/actions/setup-node-pnpm/action.yml",
    ".github/actions/setup-node-pnpm/README.md",
    ".github/actions/security-scan/action.yml",
    ".github/actions/security-scan/README.md",
    "scripts/tooling/.gitkeep"
)

# Baseline contents
$readme = @"
# ORG-GOVERNANCE

Centralized governance and standards for the organization.
"@

$repoGovernance = @"
# Repository Governance

This repository defines organization-wide governance, standards, and templates.
"@

$placeholders = @{
    "README.md" = $readme
    "REPO_GOVERNANCE.md" = $repoGovernance
    "docs/templates/pull-request-template.md" = "# Pull Request Template`n"
    "docs/templates/copilot-instructions.md" = "# Copilot Instructions`n"
    ".github/workflows/pr-check.yml" = "name: pr-check`n`non: workflow_call`n`npermissions: {}`n`n" 
    ".github/workflows/release.yml" = "name: release`n`non: workflow_call`n`npermissions: {}`n`n"
    ".github/workflows/schedule.yml" = "name: schedule`n`non: workflow_call`n`npermissions: {}`n`n"
    ".github/actions/setup-node-pnpm/action.yml" = "name: setup-node-pnpm`ndescription: Composite action placeholder`nruns:`n  using: composite`n  steps: []`n"
    ".github/actions/security-scan/action.yml" = "name: security-scan`ndescription: Composite action placeholder`nruns:`n  using: composite`n  steps: []`n"
}

foreach ($relative in $paths) {
    $full = Join-Path $root $relative
    if ($placeholders.ContainsKey($relative)) {
        New-File -Path $full -Content $placeholders[$relative]
    } else {
        New-File -Path $full -Content "# Placeholder`n"
    }
}

Write-Host "Initialized ORG-GOVERNANCE structure at $root"
